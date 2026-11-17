// BASIC# portable BSBC Profile 1 execution engine.
// Unaccepted v0.0.85 candidate: executes validated Profile 1 bytecode only.
// No Ruby, eval, network requests, arbitrary JavaScript execution or BSIR fallback.
// This class deliberately takes binary bytes, not an unvalidated model.
import {loadProfile1} from './bsharp_bsbc_loader.mjs';

export class BSBCVMError extends Error {
  constructor(message) { super(message); this.name = 'BSBCVMError'; }
}
const fail = message => { throw new BSBCVMError(message); };
const NONE = 0xffffffff;
const MAX = 2147483647;
const MAX_FOLLOWUPS = 64;
const MAX_RULE_FIRINGS = 256;
const MAX_ACTION_STEPS = 10000;
const MAX_EVENT_CHOICES = 120;

const eventWords = new Map([
  ['attacks','attack'],['attack','attack'],['takes','take'],['take','take'],
  ['opens','open'],['open','open'],['closes','close'],['close','close'],
  ['locks','lock'],['lock','lock'],['unlocks','unlock'],['unlock','unlock'],
  ['examines','examine'],['examine','examine'],['speaks','speak'],['speak','speak'],
  ['sounds','sound'],['sound','sound'],['drops','drop'],['drop','drop'],
  ['carries','carry'],['carry','carry'],['damages','damage'],['damage','damage'],
  ['changes','change'],['change','change'],['gives','give'],['give','give'],
  ['eats','eat'],['eat','eat'],['wears','wear'],['wear','wear'],
  ['removes','remove'],['remove','remove']
]);
const thirdPerson = Object.freeze({
  attack:'attacks', take:'takes',open:'opens',close:'closes',lock:'locks',
  unlock:'unlocks',examine:'examines',speak:'speaks',sound:'sounds',
  drop:'drops',carry:'carries',damage:'damages',change:'changes',
  give:'gives',eat:'eats',wear:'wears',remove:'removes'
});
const normalize = text => String(text ?? '').trim()
  .replace(/@(?=[a-z])/giu,'').replace(/\s+/gu,' ').toLowerCase();
function ensureWhole(value,where) {
  if(!Number.isSafeInteger(value)||value<0||value>MAX)fail(where+' must remain between 0 and '+MAX+'.');
}
function asName(value) {
  return typeof value==='string'?value:'';
}

export class BSharpBytecodeVM {
  // Construct only from binary; loadProfile1 validates all sections/operands.
  constructor(bytes, {expectedFingerprint=null}={}) {
    this.program = loadProfile1(bytes,{expectedFingerprint});
    this.thingIndexes = new Map(this.program.things.map((thing,index)=>[thing.name,index]));
    this.kindIndexes = new Map(this.program.kinds.map((kind,index)=>[kind.name,index]));
    this.reset();
  }
  string(index) {
    return this.program.strings[index];
  }
  thing(index) {
    const thing=this.world[index];
    if(!thing)fail('BSBC selected a Thing that is not in the world.');
    return thing;
  }
  kindDistance(actual,ancestor) {
    let current=actual,distance=0;
    while(current!==NONE) {
      if(current===ancestor)return distance;
      current=this.program.kinds[current].parent;
      distance++;
    }
    return null;
  }
  snapshot() {
    return this.world.map(thing=>({
      name:thing.name, kind:this.program.kinds[thing.kindIndex].name,
      builtin:thing.name==='player',
      states:[...thing.states].sort(),relations:{...thing.relations},
      values:{...thing.values}
    }));
  }
  reset() {
    this.world=this.program.things.map(thing=>({
      name:thing.name,kindIndex:thing.kindIndex,
      states:new Set(),relations:Object.create(null),values:{damage:0}
    }));
    this.trace=[];
    this.active=this.program.ifRules.map(()=>false);
    this.followUps=[];
    this.draining=false;
    this.stepCount=0;
    for(const record of this.program.startRecords) {
      const o=record.operands,target=this.thing(o[0]);
      switch(record.name) {
        case 'START_STATE':
          this.setState(target,this.string(o[1]),o[2]===NONE?null:this.string(o[2]));
          this.trace.push('START: '+target.name+' is '+this.string(o[1]));
          break;
        case 'START_RELATION':
          target.relations[this.string(o[1])]=this.thing(o[2]).name;
          this.trace.push('START: '+target.name+' '+this.string(o[1])+' '+this.thing(o[2]).name);
          break;
        case 'START_VALUE':
          target.values[this.string(o[1])]=o[2];
          this.trace.push('START: '+target.name+' has '+o[2]+' '+this.string(o[1]));
          break;
        default:fail('Unsupported START opcode '+record.name+'.');
      }
    }
    this.trace.push('START finished using BSBC Profile 1.');
    this.settle('START');
    this.drainFollowUps();
    return this.snapshot();
  }
  setState(target,newState,opposite=null) {
    if(opposite!==null)target.states.delete(opposite);
    target.states.add(newState);
  }
  compareReference(selector,index,name) {
    if(selector===255)return name===''?0:null;
    const thingIndex=this.thingIndexes.get(name);
    if(thingIndex===undefined)return null;
    if(selector===1)return index===thingIndex?0:null;
    if(selector===2)return this.kindDistance(this.program.things[thingIndex].kindIndex,index);
    return null;
  }
  compareEvent(rule,event) {
    if(this.string(rule.actionStringIndex)!==event.action)return null;
    const a=this.compareReference(rule.actorSelector,rule.actorReference,event.actor);
    const b=this.compareReference(rule.targetSelector,rule.targetReference,event.target);
    return a===null||b===null?null:a+b;
  }
  bestRule(event) {
    let best=null,distance=Infinity,generic=Infinity;
    for(let i=0;i<this.program.events.length;i++) {
      const rule=this.program.events[i];
      const d=this.compareEvent(rule,event);
      if(d===null)continue;
      const count=(rule.actorSelector===2?1:0)+(rule.targetSelector===2?1:0);
      if(d<distance||(d===distance&&count<generic)) {
        distance=d;generic=count;best=i;
      }
    }
    return best;
  }
  parseEvent(text) {
    const words=normalize(text).split(' ').filter(Boolean);
    if(words.length<2)fail('Enter an event such as PLAYER attacks @goblin.');
    const candidates=[];
    for(let i=1;i<words.length;i++) {
      const action=eventWords.get(words[i]);
      if(!action)continue;
      const actor=words.slice(0,i).join(' ');
      const target=words.slice(i+1).join(' ');
      if(!this.thingIndexes.has(actor))continue;
      if(target!==''&&!this.thingIndexes.has(target))continue;
      candidates.push({actor,target,action});
    }
    if(candidates.length===0)fail('Event uses an unknown Thing or action. Define the Things and use a known WHEN event.');
    for(const candidate of candidates)if(this.bestRule(candidate)!==null)return candidate;
    fail('No matching BSBC WHEN rule for "'+text.trim()+'".');
  }
  eventOptions() {
    const selected=[],seen=new Set();
    for(const rule of this.program.events) {
      const actors=this.referenceCandidates(rule.actorSelector,rule.actorReference);
      const targets=this.referenceCandidates(rule.targetSelector,rule.targetReference);
      for(const actor of actors)for(const target of targets) {
        const event={actor,target,action:this.string(rule.actionStringIndex)};
        const index=this.bestRule(event);
        if(index===null)continue;
        const key=actor+'\0'+event.action+'\0'+target;
        if(seen.has(key))continue;
        seen.add(key);
        selected.push({index,actor,target,
          label:[actor,thirdPerson[event.action]||event.action,target].filter(Boolean).join(' ')});
        if(selected.length>=MAX_EVENT_CHOICES)return selected;
      }
    }
    return selected;
  }
  referenceCandidates(selector,reference) {
    if(selector===255)return [''];
    if(selector===1)return [this.thing(reference).name];
    if(selector===2)return this.world.filter(thing=>this.kindDistance(thing.kindIndex,reference)!==null).map(thing=>thing.name);
    fail('Unsupported event selector '+selector+'.');
  }
  runEventText(text) {
    const event=this.parseEvent(text);
    return this.runEvent(this.bestRule(event),event);
  }
  runEvent(index,invocation=null) {
    if(!Number.isInteger(index)||index<0||index>=this.program.events.length)fail('Choose a listed BSBC WHEN event.');
    const rule=this.program.events[index];
    const event={
      actor:invocation?.actor ?? (rule.actorSelector===1?this.thing(rule.actorReference).name:null),
      target:invocation?.target ?? (rule.targetSelector===1?this.thing(rule.targetReference).name:rule.targetSelector===255?'':null),
      action:this.string(rule.actionStringIndex)
    };
    if(typeof event.actor!=='string'||typeof event.target!=='string')fail('Select concrete Things before running a Kind event.');
    if(this.compareEvent(rule,event)===null)fail('This selected event does not match its BSBC WHEN rule.');
    if(this.bestRule(event)!==index)fail('A more specific WHEN rule handles this event.');
    this.followUps=[];
    this.stepCount=0;
    try {
      this.processEvent(index,event);
      this.drainFollowUps();
    } catch(error) {
      this.followUps=[];
      throw error;
    }
    return this.snapshot();
  }
  bindingsFor(rule,event) {
    const map=new Map();
    const refs=[
      [rule.actorSelector,rule.actorReference,event.actor],
      [rule.targetSelector,rule.targetReference,event.target]
    ];
    for(const [selector,kindIndex,name] of refs) {
      if(selector!==2)continue;
      const index=this.thingIndexes.get(name);
      if(index===undefined)fail('Event Kind reference is missing its Thing.');
      if(map.has(kindIndex)&&map.get(kindIndex)!==index) {
        fail('One event bound the same #Kind to different Things.');
      }
      map.set(kindIndex,index);
    }
    return map;
  }
  processEvent(index,event) {
    const rule=this.program.events[index];
    const bindings=this.bindingsFor(rule,event);
    this.trace.push('EVENT (BSBC): '+[event.actor,event.action,event.target].filter(Boolean).join(' '));
    const actorIndex=this.thingIndexes.get(event.actor);
    this.executeBlock(rule.blockIndex,{actorIndex,bindings});
    this.settle('event');
  }
  actionTargets(selector,ref,bindings) {
    switch(selector) {
      case 1:return [ref];
      case 3: {
        const selected=bindings.get(ref);
        if(selected===undefined)fail('No event binding exists for '+this.program.kinds[ref].name+'.');
        return [selected];
      }
      case 4: {
        const items=this.world.map((thing,index)=>({thing,index}))
          .filter(x=>this.kindDistance(x.thing.kindIndex,ref)!==null).map(x=>x.index);
        if(items.length>512)fail('An every #Kind instruction selected too many Things.');
        return items;
      }
      default:fail('Unsupported BSBC action selector '+selector+'.');
    }
  }
  causedReference(selector,ref,bindings) {
    if(selector===255)return '';
    if(selector===1)return this.thing(ref).name;
    if(selector===3) {
      const selected=bindings.get(ref);
      if(selected===undefined)fail('Caused event refers to an unbound Kind.');
      return this.thing(selected).name;
    }
    // ONE_KIND in CAUSE_EVENT cannot be given a deterministic single Thing
    // without a concrete selector algorithm: reject instead of guessing.
    fail('A caused ONE_KIND event needs a concrete Thing selection, not implemented in this VM.');
  }
  stageCause(op,bindings) {
    const [aSel,aRef,word,tSel,tRef]=op;
    const event={
      actor:this.causedReference(aSel,aRef,bindings),
      action:this.string(word),
      target:this.causedReference(tSel,tRef,bindings)
    };
    this.followUps.push(event);
    this.trace.push('(cause '+[event.actor,event.action,event.target].filter(Boolean).join(' ')+' → queued');
  }
  preflight(instruction,targets) {
    const op=instruction.operands;
    if(instruction.name==='DAMAGE') {
      for(const index of targets) {
        const current=this.thing(index).values.damage;
        if(current>MAX-op[2])fail(this.thing(index).name+' damage would exceed '+MAX+'.');
      }
    }
    if(instruction.name==='CHANGE_VALUE') {
      const value=this.string(op[2]);
      for(const index of targets) {
        const thing=this.thing(index),current=thing.values[value];
        if(!Number.isSafeInteger(current))fail(thing.name+' has no established whole-number '+value+' value.');
      }
    }
  }
  executeBlock(index,{actorIndex=null,bindings=new Map()}={}) {
    const block=this.program.blocks[index];
    if(!block)fail('Invalid BSBC CODE block '+index+'.');
    const stagedStart=this.followUps.length;
    try {
      for(const instruction of block.instructions) {
        if(++this.stepCount>MAX_ACTION_STEPS)fail('BSBC execution exceeded '+MAX_ACTION_STEPS+' actions.');
        const op=instruction.operands;
        if(instruction.name==='CAUSE_EVENT') {
          this.stageCause(op,bindings);
          continue;
        }
        const targets=this.actionTargets(op[0],op[1],bindings);
        this.preflight(instruction,targets);
        if(targets.length===0) {
          this.trace.push('Action selected no matching Things.');
          continue;
        }
        for(const index of targets)this.executeAction(instruction,index,actorIndex);
      }
    } catch(error) {
      // Follow-ups from a failed Body never execute, even when earlier
      // actions in that Body already changed world state.
      this.followUps.length=stagedStart;
      throw error;
    }
  }
  executeAction(instruction,index,actorIndex) {
    const thing=this.thing(index),o=instruction.operands;
    switch(instruction.name) {
      case 'DAMAGE': {
        const amount=o[2],next=thing.values.damage+amount;
        ensureWhole(next,'Damage');
        thing.values.damage=next;
        this.trace.push('(damage '+thing.name+' by '+amount+' → damage '+next);
        return;
      }
      case 'CHANGE_STATE': {
        const state=this.string(o[2]),opposite=o[3]===NONE?null:this.string(o[3]);
        this.setState(thing,state,opposite);
        this.trace.push('(change '+thing.name+' to '+state);
        return;
      }
      case 'CHANGE_VALUE': {
        const value=this.string(o[2]),next=o[3];
        thing.values[value]=next;
        this.trace.push('(change '+value+' of '+thing.name+' to '+next);
        return;
      }
      case 'CARRY': {
        delete thing.relations.on;delete thing.relations.in;
        thing.relations['carried by']=actorIndex===null?'player':this.thing(actorIndex).name;
        this.trace.push('(carry '+thing.name+' → '+thing.relations['carried by']);
        return;
      }
      case 'UNLOCK': {
        this.setState(thing,'unlocked','locked');
        this.trace.push('(unlock '+thing.name);
        return;
      }
      default:fail('Unsupported BSBC action '+instruction.name+'.');
    }
  }
  evaluate(condition) {
    const o=condition.operands,thing=this.thing(o[0]);
    switch(condition.name) {
      case 'STATE_IS':return thing.states.has(this.string(o[1]));
      case 'STATE_ISNT':return !thing.states.has(this.string(o[1]));
      case 'RELATION_EXISTS':return thing.relations[this.string(o[1])]===this.thing(o[2]).name;
      case 'VALUE_EQUALS':return thing.values[this.string(o[1])]===o[2];
      default:fail('Unsupported BSBC condition '+condition.name+'.');
    }
  }
  settle(reason) {
    const limit=Math.max(MAX_RULE_FIRINGS,this.program.ifRules.length*8);
    let fired=0,moved=true;
    while(moved) {
      moved=false;
      for(let i=0;i<this.program.ifRules.length;i++) {
        const rule=this.program.ifRules[i],current=this.evaluate(rule.condition);
        if(!current) {this.active[i]=false;continue;}
        if(this.active[i])continue;
        if(++fired>limit)fail('IF rules kept triggering and were stopped at '+limit+' reactions.');
        this.active[i]=true;
        this.trace.push('IF (BSBC): '+rule.condition.name+' ['+reason+']');
        this.executeBlock(rule.blockIndex);
        moved=true;
      }
    }
  }
  drainFollowUps() {
    if(this.draining)return;
    this.draining=true;
    let count=0;
    try {
      while(this.followUps.length) {
        if(++count>MAX_FOLLOWUPS)fail('Caused events kept triggering: stopped after '+MAX_FOLLOWUPS+' follow-ups.');
        const event=this.followUps.shift();
        const index=this.bestRule(event);
        if(index===null) {
          this.trace.push('FOLLOW-UP: no matching WHEN for '+
            [event.actor,event.action,event.target].filter(Boolean).join(' '));
          continue;
        }
        this.processEvent(index,event);
      }
    } finally {
      this.draining=false;
      this.followUps=[];
    }
  }
}
