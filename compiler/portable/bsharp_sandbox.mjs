// BASIC# browser sandbox runtime, unaccepted v0.0.85 candidate.
// Executes only the subset emitted by compiler/portable/bsharp_compiler.mjs.
// This is NOT the accepted BSBC VM. It never evaluates creator code as JavaScript.

export class SandboxError extends Error {
  constructor(message) {
    super(message);
    this.name = 'SandboxError';
  }
}
const invalid = message => { throw new SandboxError(message); };
const opposite = Object.freeze({
  open: 'closed', closed: 'open', locked: 'unlocked', unlocked: 'locked',
  alive: 'dead', dead: 'alive', calm: 'angry', angry: 'calm',
  friendly: 'hostile', hostile: 'friendly', visible: 'hidden',
  hidden: 'visible', carried: 'dropped', dropped: 'carried',
  broken: 'whole', whole: 'broken', on: 'off', off: 'on'
});
const supportedActions = new Set(['change', 'damage', 'increase', 'decrease', 'carry', 'unlock', 'cause']);
const clone = value => JSON.parse(JSON.stringify(value));
const display = ref => ref && ref.name ? ref.name : 'unknown';

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
const normalizeEventName = text => String(text).trim().replace(/@(?=[a-z])/giu,'').replace(/\s+/gu,' ').toLowerCase();
function checkReference(ref, known, where, kindNames = null, binding = null) {
  if (ref && ref.type === 'object' && known.has(ref.name)) return;
  if (ref && ['kind','kind_one'].includes(ref.type) && kindNames?.has(ref.kind_name) && where.startsWith('WHEN')) return;
  if (ref && ref.type === 'kind_set' && kindNames?.has(ref.kind_name) && where === 'Action') return;
  if (ref && ref.type === 'previous' && binding?.has(ref.kind_name)) return;
  invalid(where + ' contains an unknown or unsupported selector. Use @Thing, PLAYER, or an established WHEN Kind reference.');
}
function checkCondition(value, known) {
  if (!value || typeof value !== 'object') invalid('A BASIC# IF has no valid condition.');
  if (value.connector) {
    if (value.connector !== 'and' && value.connector !== 'or') invalid('Unsupported IF connector.');
    if (!Array.isArray(value.clauses) || value.clauses.length < 2) invalid('A compound IF needs at least two complete clauses.');
    value.clauses.forEach(item => checkCondition(item, known));
    return;
  }
  checkReference(value.subject, known, 'IF');
  if (value.relation === 'has') {
    if (!/^[a-z][a-z0-9]*$/u.test(value.value_name || '')) invalid('An IF comparison needs a valid value name.');
    if (Object.hasOwn(value,'text_value')) {
      if (typeof value.text_value !== 'string' || value.comparison) invalid('Text comparison must use equality.');
    } else {
      if (!Number.isSafeInteger(value.amount) || value.amount < 0 || value.amount > 2147483647) invalid('Invalid whole-number comparison.');
      if (!['equals','at_least','more_than','at_most','less_than'].includes(value.comparison || 'equals')) {
        invalid('Unsupported number comparison.');
      }
    }
  } else if ((value.relation === 'is' || value.relation === 'isnt') && value.value && value.value.kind === 'state') {
    if (typeof value.value.name !== 'string') invalid('Invalid state name.');
  } else invalid('Unsupported IF comparison in this browser sandbox.');
}
function checkAction(action, known, kindNames = null, binding = null) {
  if (!action || !supportedActions.has(action.action)) invalid('Action (' + (action && action.action || 'unknown') + ' is not implemented in this browser sandbox.');
  if (action.action === 'cause') {
    if (!action.event || typeof action.event.action !== 'string') invalid('(cause requires a valid event.');
    for (const ref of [action.event.actor,action.event.target]) {
      if (!ref || !['object','previous'].includes(ref.type)) invalid('Caused events must name one Thing or use an established event binding.');
      checkReference(ref,known,'Caused event',kindNames,binding);
    }
    return;
  }
  checkReference(action.target, known, 'Action', kindNames, binding);
  if (action.action === 'change') {
    if (action.value_name) {
      if (!/^[a-z][a-z0-9]*$/u.test(action.value_name)) invalid('A changed value needs a valid name.');
      if (Object.hasOwn(action,'to_text')) {
        if (typeof action.to_text !== 'string' || action.value_name === 'damage') invalid('Damage cannot store text.');
      } else if (!Number.isSafeInteger(action.to_amount) || action.to_amount < 0 || action.to_amount > 2147483647) {
        invalid('Changed whole-number values must be within supported range.');
      }
    } else if (!action.to || action.to.kind !== 'state' || !action.to.name) {
      invalid('Use (change @Thing to state or (change title of @Thing to "text".');
    }
  }
  if (['increase', 'decrease', 'damage'].includes(action.action)) {
    if (!Number.isSafeInteger(action.amount) || action.amount < 1 || action.amount > 2147483647) invalid('Action amounts must be positive whole numbers.');
  }
  if (['increase', 'decrease'].includes(action.action) && !/^[a-z][a-z0-9]*$/u.test(action.value_name || '')) invalid('A number change needs a valid value name.');
}
function validate(ir) {
  if (!ir || ir.format !== 'bsir.debug.json') invalid('Expected a BSharp IR document.');
  if (!Array.isArray(ir.objects) || !Array.isArray(ir.events) || !Array.isArray(ir.if_rules) || !Array.isArray(ir.facts)) invalid('Incomplete BSharp IR document.');
  if ((ir.controls || []).length || (ir.hover_declarations || []).length || (ir.context_declarations || []).length) {
    invalid('This browser sandbox does not execute CONTROLS, HOVER or CONTEXT yet.');
  }
  const known = new Set();
  for (const thing of ir.objects) {
    if (!thing.name || known.has(thing.name)) invalid('Duplicate or unnamed Thing in BSharp IR.');
    known.add(thing.name);
  }
  if (!known.has('player')) invalid('BSharp IR must include PLAYER.');
  for (const fact of ir.facts) {
    checkReference(fact.subject, known, 'START');
    if (fact.relation === 'has') {
      if (!/^[a-z][a-z0-9]*$/u.test(fact.value_name || '')) invalid('Unsupported START value name.');
      if (Object.hasOwn(fact,'text_value')) {
        if (typeof fact.text_value !== 'string' || fact.value_name === 'damage') invalid('Invalid START text value.');
      } else if (!Number.isSafeInteger(fact.amount) || fact.amount < 0 || fact.amount > 2147483647) {
        invalid('Invalid START whole-number value.');
      }
    } else if (fact.relation === 'is') {
      if (!fact.value || fact.value.kind !== 'state' || !fact.value.name) invalid('Unsupported START state.');
    } else invalid('Unsupported START relation.');
  }
  const kindNames = new Set(['thing','place','actor','person','creature','door','container',
    'supporter','key','weapon','food','clothing','device','guard','table']);
  for (const kind of ir.kinds || []) kindNames.add(kind.name);
  for (const evt of ir.events) {
    if (!evt.when) invalid('Invalid WHEN event.');
    checkReference(evt.when.actor, known, 'WHEN actor', kindNames);
    checkReference(evt.when.target, known, 'WHEN target', kindNames);
    if (!evt.when.action || !Array.isArray(evt.then) || !evt.then.length) invalid('WHEN must have an event and at least one action.');
    const binding=new Set([evt.when.actor,evt.when.target].filter(ref => ref && ['kind','kind_one'].includes(ref.type)).map(ref=>ref.kind_name));
    evt.then.forEach(action => checkAction(action, known, kindNames, binding));
  }
  for (const rule of ir.if_rules) {
    checkCondition(rule.if, known);
    if (!Array.isArray(rule.then) || !rule.then.length) invalid('IF needs at least one action.');
    rule.then.forEach(action => checkAction(action, known, kindNames));
    if (Object.hasOwn(rule, 'otherwise')) {
      if (!Array.isArray(rule.otherwise) || !rule.otherwise.length) invalid('OTHERWISE needs at least one action.');
      rule.otherwise.forEach(action => checkAction(action, known, kindNames));
    }
  }
}

export class BSharpSandbox {
  constructor(ir) {
    validate(ir);
    this.ir = clone(ir);
    this.kindParents = new Map((ir.kinds || []).map(kind => [kind.name,kind.parent]));
    this.objects = new Map();
    this.trace = [];
    this.active = [];
    this.reset();
  }
  reset() {
    this.objects.clear();
    for (const item of this.ir.objects) {
      this.objects.set(item.name, {
        name: item.name, kind: item.kind, builtin: !!item.builtin,
        states: new Set(), relations: {}, values: { damage: 0 }
      });
    }
    this.trace = [];
    this.followUps = [];
    this.draining = false;
    this.active = this.ir.if_rules.map(rule => Object.hasOwn(rule, 'otherwise') ? null : false);
    for (const fact of this.ir.facts) {
      const thing = this.objects.get(fact.subject.name);
      if (fact.relation === 'has') {
        const value = Object.hasOwn(fact,'text_value') ? fact.text_value : fact.amount;
        thing.values[fact.value_name] = value;
        this.trace.push('START: ' + thing.name + ' has ' + JSON.stringify(value) + ' ' + fact.value_name);
      } else {
        this.setState(thing, fact.value.name);
        this.trace.push('START: ' + thing.name + ' is ' + fact.value.name);
      }
    }
    this.trace.push('START finished.');
    this.settle('START');
    this.drainFollowUps();
    return this.snapshot();
  }
  snapshot() {
    return [...this.objects.values()].map(thing => ({
      name: thing.name, kind: thing.kind, builtin: thing.builtin,
      states: [...thing.states].sort(), relations: {...thing.relations},
      values: {...thing.values}
    }));
  }
  kindDistance(actual, expected) {
    let current=actual,depth=0;
    const visited=new Set();
    while(current && !visited.has(current)) {
      if(current===expected) return depth;
      visited.add(current);
      current=this.kindParents.get(current) || null;
      depth++;
    }
    return null;
  }
  eventReferenceDistance(reference, name) {
    const thing=this.objects.get(name);
    if(!thing) return null;
    if(reference.type==='object') return reference.name===name ? 0 : null;
    if(['kind','kind_one'].includes(reference.type)) return this.kindDistance(thing.kind,reference.kind_name);
    return null;
  }
  eventCandidates(reference) {
    if(reference.type==='object') return [reference.name];
    return [...this.objects.values()].filter(thing => this.eventReferenceDistance(reference,thing.name)!==null).map(thing=>thing.name);
  }
  bestRule(invocation) {
    let best=null,bestScore=Infinity,bestSelectors=Infinity;
    for(let index=0;index<this.ir.events.length;index++) {
      const rule=this.ir.events[index];
      const score=this.matchRule(rule,invocation);
      if(score===null) continue;
      // Equal Kind distance must still prefer a named Thing over a #Kind matcher.
      const selectors=[rule.when.actor,rule.when.target].filter(ref=>ref.type!=='object').length;
      if(score<bestScore || (score===bestScore && selectors<bestSelectors)) {
        best=index;bestScore=score;bestSelectors=selectors;
      }
    }
    return best;
  }
  eventOptions() {
    const options=[],seen=new Set();
    const shownVerb={attack:'attacks',take:'takes',open:'opens',close:'closes',
      lock:'locks',unlock:'unlocks',speak:'speaks',examine:'examines',
      sound:'sounds',carry:'carries',drop:'drops',damage:'damages',
      change:'changes',give:'gives',eat:'eats',wear:'wears',remove:'removes'};
    for(let index=0;index<this.ir.events.length;index++) {
      const rule=this.ir.events[index];
      for(const actor of this.eventCandidates(rule.when.actor)) {
        for(const target of this.eventCandidates(rule.when.target)) {
          const invocation={actor,target,action:rule.when.action};
          const key=actor+'|'+rule.when.action+'|'+target;
          if(seen.has(key)||this.bestRule(invocation)!==index) continue;
          seen.add(key);
          options.push({index,actor,target,
            label:actor+' '+(shownVerb[rule.when.action]||rule.when.action)+' '+target});
          if(options.length>=120) return options;
        }
      }
    }
    return options;
  }
  parseEventText(text) {
    const words=normalizeEventName(text).split(' ');
    for(let i=1;i<words.length-1;i++) {
      const verb=eventWords.get(words[i]);
      if(!verb) continue;
      const actor=words.slice(0,i).join(' '),target=words.slice(i+1).join(' ');
      if(this.objects.has(actor)&&this.objects.has(target)) return {actor,target,action:verb};
    }
    invalid('Event must look like PLAYER attacks @goblin, using Things defined in DEFINE.');
  }
  matchRule(rule, invocation) {
    if(rule.when.action!==invocation.action) return null;
    const actorDistance=this.eventReferenceDistance(rule.when.actor,invocation.actor);
    const targetDistance=this.eventReferenceDistance(rule.when.target,invocation.target);
    return actorDistance===null||targetDistance===null ? null : actorDistance+targetDistance;
  }
  runEventText(text) {
    const invocation=this.parseEventText(text);
    const best=this.bestRule(invocation);
    if(best===null) invalid('No WHEN rule matched "'+text.trim()+'".');
    return this.runEvent(best,invocation);
  }
  setState(thing, newState) {
    if (opposite[newState]) thing.states.delete(opposite[newState]);
    thing.states.add(newState);
  }
  evaluate(rule) {
    if (rule.connector) {
      return rule.connector === 'and'
        ? rule.clauses.every(clause => this.evaluate(clause))
        : rule.clauses.some(clause => this.evaluate(clause));
    }
    const thing = this.objects.get(rule.subject.name);
    if (rule.relation === 'is') return thing.states.has(rule.value.name);
    if (rule.relation === 'isnt') return !thing.states.has(rule.value.name);
    if (rule.relation === 'has') {
      const current = thing.values[rule.value_name];
      if (Object.hasOwn(rule,'text_value')) return current === rule.text_value;
      if (!Number.isSafeInteger(current)) return false;
      switch (rule.comparison || 'equals') {
        case 'equals': return current === rule.amount;
        case 'at_least': return current >= rule.amount;
        case 'more_than': return current > rule.amount;
        case 'at_most': return current <= rule.amount;
        case 'less_than': return current < rule.amount;
        default: invalid('Unknown IF number comparison.');
      }
    }
    invalid('The requested IF comparison is not implemented.');
  }
  resolveActionName(ref, context = null) {
    const name = ref.type === 'previous' ? context?.bindings?.[ref.kind_name] : ref.name;
    if (!name || !this.objects.has(name)) invalid('An event reference did not select a defined Thing.');
    return name;
  }
  stageFollowUp(action, context) {
    const actor=this.resolveActionName(action.event.actor,context);
    const target=this.resolveActionName(action.event.target,context);
    const entry={actor,target,action:action.event.action};
    this.followUps.push(entry);
    this.trace.push('(cause '+actor+' '+entry.action+' '+target+' → queued follow-up event');
  }
  apply(action, context = null) {
    if(action.action === 'cause') {
      this.stageFollowUp(action,context);
      return;
    }
    if(action.target.type === 'kind_set') {
      const targets=[...this.objects.values()].filter(obj=>this.kindDistance(obj.kind,action.target.kind_name)!==null);
      if(targets.length===0) {
        this.trace.push('every #'+action.target.kind_name+' found no Things');
      }
      if(targets.length>512) invalid('An every #Kind action selected too many Things for this browser sandbox.');
      for(const obj of targets) {
        this.apply({...action,target:{type:'object',name:obj.name}},context);
      }
      return;
    }
    const name=action.target.type==='previous'
      ? context?.bindings?.[action.target.kind_name]
      : action.target.name;
    const thing=this.objects.get(name),word=action.action;
    if(!thing) invalid('No selected Thing for the '+action.target.kind_name+' reference.');
    if (word === 'change') {
      if (action.value_name) {
        const value = Object.hasOwn(action,'to_text') ? action.to_text : action.to_amount;
        thing.values[action.value_name] = value;
        this.trace.push('(change ' + action.value_name + ' of ' + thing.name + ' to ' + JSON.stringify(value) + ' → updated');
        return;
      }
      this.setState(thing, action.to.name);
      this.trace.push('(change ' + thing.name + ' to ' + action.to.name + ' → ' + thing.name + ' is now ' + action.to.name);
      return;
    }
    if (word === 'damage') {
      const next = thing.values.damage + action.amount;
      if (!Number.isSafeInteger(next)) invalid('Damage exceeded supported whole-number range.');
      thing.values.damage = next;
      this.trace.push('(damage ' + thing.name + ' by ' + action.amount + ' → damage is ' + next);
      return;
    }
    if (word === 'increase' || word === 'decrease') {
      const old = thing.values[action.value_name];
      if (!Number.isSafeInteger(old)) invalid('START must establish ' + action.value_name + ' of ' + thing.name + ' before it can change.');
      const next = old + (word === 'increase' ? action.amount : -action.amount);
      if (!Number.isSafeInteger(next)) invalid('Number change exceeded the safe whole-number range.');
      thing.values[action.value_name] = next;
      this.trace.push('(' + word + ' ' + action.value_name + ' of ' + thing.name + ' by ' + action.amount + ' → ' + next);
      return;
    }
    if (word === 'carry') {
      thing.relations['carried by'] = context?.actor || 'player';
      delete thing.relations.in; delete thing.relations.on;
      this.trace.push('(carry ' + thing.name + ' → carried by ' + (context?.actor || 'player'));
      return;
    }
    if (word === 'unlock') {
      this.setState(thing, 'unlocked');
      this.trace.push('(unlock ' + thing.name + ' → unlocked');
      return;
    }
    invalid('Unsupported browser action: ' + word);
  }
  settle(reason) {
    // React once on false-to-true for IF, or on either branch transition for OTHERWISE.
    // Run again after actions change the world. Refuse endless reactions.
    const limit = Math.max(128, this.ir.if_rules.length * 8);
    let fired = 0;
    let moved = true;
    while (moved) {
      moved = false;
      for (let i = 0; i < this.ir.if_rules.length; i++) {
        const rule = this.ir.if_rules[i], current = this.evaluate(rule.if);
        const both = Object.hasOwn(rule, 'otherwise');
        const prior = this.active[i];
        if (both ? prior === current : !current || prior === true) {
          this.active[i] = current;
          continue;
        }
        this.active[i] = current;
        const branch = current ? 'IF' : 'OTHERWISE';
        this.trace.push(branch + ' ' + rule.if.raw + ' [' + reason + ']');
        const commands = current ? rule.then : rule.otherwise;
        for (const action of commands) this.apply(action);
        moved = true;
        fired++;
        if (fired > limit) invalid('IF rules kept triggering each other. Execution stopped to prevent an endless loop.');
      }
    }
  }
  processEvent(index, invocation = null) {
    if (!Number.isInteger(index) || index < 0 || index >= this.ir.events.length) invalid('Choose a listed WHEN event.');
    const rule=this.ir.events[index];
    const actor=invocation?.actor || (rule.when.actor.type==='object' ? rule.when.actor.name : null);
    const target=invocation?.target || (rule.when.target.type==='object' ? rule.when.target.name : null);
    if(!actor || !target) invalid('A kind-based WHEN needs a selected actor and target.');
    const resolved={actor,target,action:rule.when.action};
    if(this.matchRule(rule,resolved)===null) invalid('Selected Thing does not match this WHEN rule.');
    const bindings={};
    for(const [ref,name] of [[rule.when.actor,actor],[rule.when.target,target]]) {
      if(['kind','kind_one'].includes(ref.type)) {
        if(bindings[ref.kind_name] && bindings[ref.kind_name]!==name) {
          invalid('The same #Kind was selected more than once in one event. Use named Things to disambiguate.');
        }
        bindings[ref.kind_name]=name;
      }
    }
    this.trace.push('EVENT: '+actor+' '+rule.when.action+' '+target);
    const context={actor,bindings};
    for(const action of rule.then) this.apply(action,context);
    this.settle('event');
  }
  drainFollowUps() {
    if(this.draining) return;
    this.draining=true;
    let count=0;
    try {
      while(this.followUps.length) {
        if(++count>64) invalid('Follow-up event limit (64) reached. Execution stopped to prevent an endless event chain.');
        const next=this.followUps.shift();
        const rule=this.bestRule(next);
        if(rule===null) {
          this.trace.push('FOLLOW-UP: no WHEN rule for '+next.actor+' '+next.action+' '+next.target);
          continue;
        }
        this.processEvent(rule,next);
      }
    } finally {
      this.draining=false;
      this.followUps=[];
    }
  }
  runEvent(index, invocation = null) {
    if (!this.draining) this.followUps=[];
    this.processEvent(index,invocation);
    this.drainFollowUps();
    return this.snapshot();
  }

}
