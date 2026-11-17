// BASIC# portable BSBC Profiles 1-3 execution engine.
// Unaccepted v0.0.85 source-only candidate: bounded Profile 3 interactions.
// No Ruby, eval, network requests, arbitrary JavaScript execution or BSIR fallback.
// This class deliberately takes binary bytes, not an unvalidated model.
import {loadBSBC} from './bsharp_bsbc_loader.mjs';

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
  // Construct only from binary; loadBSBC validates all sections/operands.
  constructor(bytes, {expectedFingerprint=null}={}) {
    this.program = loadBSBC(bytes,{expectedFingerprint});
    this.thingIndexes = new Map(this.program.things.map((thing,index)=>[thing.name,index]));
    this.kindIndexes = new Map(this.program.kinds.map((kind,index)=>[kind.name,index]));
    this.reset();
  }
  // Profile 3 declarations live in validated canonical BSBC JSON sections.
  // The browser provides an engine-neutral control event bridge, not physics.
  controlBindings() {
    return this.program.controls.flatMap(decl=>decl.instructions.map(instr=>({...instr})));
  }
  keyCommand(key) {
    if(this.program.profile!=='bsharp.bytecode.v3')fail('Game controls require Profile 3.');
    const named=String(key).toUpperCase();
    const instruction=this.controlBindings().find(x=>x.type==='key_move'&&x.key===named);
    if(!instruction)fail('No declared direction control for key '+named+'.');
    const command={type:'move_intent',actor:'player',direction:instruction.direction,key:named};
    this.trace.push('CONTROL: '+named+' → '+instruction.direction+' (host-neutral intent only)');
    return command; // host adapter may consume; VM does not fake a map or movement
  }
  declarationMatches(subject,thing) {
    if(subject?.type==='object')return subject.name===thing.name;
    if(subject?.type==='kind_declaration'){
      const kind=this.kindIndexes.get(subject.kind_name);
      return kind!==undefined&&this.kindDistance(thing.kindIndex,kind)!==null;
    }
    return false;
  }
  declarations(key,thing) {
    const all=this.program[key]||[];
    return all.filter(decl=>this.declarationMatches(decl.subject,thing))
      .map((decl,i)=>{
        const kind=decl.subject.type==='kind_declaration'
          ?this.kindIndexes.get(decl.subject.kind_name):null;
        const distance=kind===null?-1:this.kindDistance(thing.kindIndex,kind);
        return {decl,index:i,rank:distance===-1?10000:1000-distance};
      })
      .sort((a,b)=>a.rank-b.rank||a.index-b.index)
      .map(row=>row.decl);
  }
  thingByName(name) {
    const normalized=normalize(name),index=this.thingIndexes.get(normalized);
    if(index===undefined)fail('Unknown Thing @'+normalized+'.');
    return this.thing(index);
  }
  hoverFor(name) {
    const thing=this.thingByName(name),fields=new Map();
    for(const decl of this.declarations('hover_declarations',thing))for(const field of decl.fields){
      let value;
      switch(field.name){
        case 'name':value=thing.name;break;
        case 'kind':value=this.program.kinds[thing.kindIndex].name;break;
        case 'state':value=[...thing.states].sort().join(', ');break;
        case 'description':
          value=thing.values.description;
          if(value===undefined)fail('@'+thing.name+' does not have description information.');
          break;
        default:fail('Unsupported hover information.');
      }
      fields.set(field.name,{field:field.name,value:String(value)});
    }
    return [...fields.values()];
  }
  contextFor(name) {
    const thing=this.thingByName(name),shown=new Map();
    for(const declaration of this.declarations('context_declarations',thing)) {
      for(const entry of declaration.entries) {
        const condition=entry.condition;
        if(condition){
          const present=thing.states.has(condition.value.name);
          if(condition.relation==='is'&&!present)continue;
          if(condition.relation==='isnt'&&present)continue;
        }
        shown.set(entry.label,{label:entry.label,action:entry.action});
      }
    }
    return [...shown.values()];
  }
  contextThing(ref,current) {
    if(ref?.type==='context_it')return current;
    if(ref?.type==='object')return this.thingByName(ref.name);
    fail('Context action has no bound Thing.');
  }
  contextAction(action,thing) {
    if(action.action==='cause') {
      const event=action.event;
      const actor=this.contextThing(event.actor,thing),target=this.contextThing(event.target,thing);
      const item={actor:actor.name,target:target.name,action:event.action};
      this.followUps.push(item);
      this.trace.push('CONTEXT (cause '+actor.name+' '+event.action+' '+target.name+' → queued');
      return;
    }
    const target=this.contextThing(action.target,thing);
    if(action.action==='change') {
      if(action.value_name) {
        const current=target.values[action.value_name];
        const next=Object.hasOwn(action,'to_text')?action.to_text:action.to_amount;
        if(typeof current!==typeof next)fail('Context value '+action.value_name+' has no established matching type.');
        if(action.value_name==='damage'&&typeof next==='string')fail('Damage cannot hold text.');
        target.values[action.value_name]=next;
        this.trace.push('CONTEXT change '+action.value_name+' of '+target.name+' to '+JSON.stringify(next));
      }else{
        const state=action.to.name;
        const opposite={
          open:'closed',closed:'open',locked:'unlocked',unlocked:'locked',
          alive:'dead',dead:'alive',calm:'angry',angry:'calm',on:'off',off:'on',
          visible:'hidden',hidden:'visible',broken:'whole',whole:'broken'
        }[state]||null;
        this.setState(target,state,opposite);
        this.trace.push('CONTEXT change '+target.name+' to '+state);
      }
      return;
    }
    if(action.action==='damage') {
      ensureWhole(target.values.damage+action.amount,'Context damage');
      target.values.damage+=action.amount;
      this.trace.push('CONTEXT damage '+target.name+' by '+action.amount);
      return;
    }
    if(action.action==='carry') {
      delete target.relations.on;delete target.relations.in;
      target.relations['carried by']='player';
      this.trace.push('CONTEXT carry '+target.name);return;
    }
    if(action.action==='unlock') {
      this.setState(target,'unlocked','locked');
      this.trace.push('CONTEXT unlock '+target.name);return;
    }
    fail('Unsupported Profile 3 context action '+action.action+'.');
  }
  executeContext(name,label) {
    if(this.program.profile!=='bsharp.bytecode.v3')fail('Context interactions require Profile 3.');
    const thing=this.thingByName(name);
    const menu=this.contextFor(name),item=menu.find(entry=>entry.label===label);
    if(!item)fail('@'+thing.name+' does not currently offer "'+label+'".');
    this.stepCount=0;this.followUps=[];
    try {
      this.contextAction(item.action,thing);
      this.settle('CONTEXT');
      this.drainFollowUps();
    }catch(error){this.followUps=[];throw error;}
    return this.snapshot();
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
        case 'START_TEXT_VALUE': {
          const name=this.string(o[1]),text=this.string(o[2]);
          if(name==='damage')fail('Damage must remain a whole-number value.');
          target.values[name]=text;
          this.trace.push('START: '+target.name+' has '+JSON.stringify(text)+' '+name);
          break;
        }
        default:fail('Unsupported START opcode '+record.name+'.');
      }
    }
    this.trace.push('START finished using '+this.program.profile+'.');
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
    if(instruction.name==='CHANGE_VALUE'||instruction.name==='CHANGE_TEXT_VALUE') {
      const value=this.string(op[2]);
      const expectedType=instruction.name==='CHANGE_TEXT_VALUE'?'string':'number';
      for(const index of targets) {
        const thing=this.thing(index),current=thing.values[value];
        if(typeof current!==expectedType||
          (expectedType==='number'&&!Number.isSafeInteger(current))) {
          fail(thing.name+' has no established '+(expectedType==='string'?'text':'whole-number')+' '+value+' value.');
        }
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
      case 'CHANGE_TEXT_VALUE': {
        const value=this.string(o[2]),next=this.string(o[3]);
        if(value==='damage')fail('Damage cannot store text.');
        thing.values[value]=next;
        this.trace.push('(change '+value+' of '+thing.name+' to '+JSON.stringify(next));
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
      case 'TEXT_VALUE_EQUALS':return thing.values[this.string(o[1])]===this.string(o[2]);
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
