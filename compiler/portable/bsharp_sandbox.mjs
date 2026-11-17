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
const supportedActions = new Set(['change', 'damage', 'increase', 'decrease', 'carry', 'unlock']);
const clone = value => JSON.parse(JSON.stringify(value));
const display = ref => ref && ref.name ? ref.name : 'unknown';

function checkReference(ref, known, where) {
  if (!ref || ref.type !== 'object' || !known.has(ref.name)) {
    invalid(where + ' uses an unsupported selector or unknown Thing. This console currently accepts @named Things and PLAYER.');
  }
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
    if (!Number.isSafeInteger(value.amount) || value.amount < 0 || !/^[a-z][a-z0-9]*$/u.test(value.value_name || '')) invalid('Unsupported IF number comparison.');
  } else if ((value.relation === 'is' || value.relation === 'isnt') && value.value && value.value.kind === 'state') {
    if (typeof value.value.name !== 'string') invalid('Invalid state name.');
  } else invalid('Unsupported IF comparison in this browser sandbox.');
}
function checkAction(action, known) {
  if (!action || !supportedActions.has(action.action)) invalid('Action (' + (action && action.action || 'unknown') + ' is not implemented in this browser sandbox.');
  checkReference(action.target, known, 'Action');
  if (action.action === 'change') {
    if (action.value_name || !action.to || action.to.kind !== 'state' || !action.to.name) invalid('This sandbox supports (change Thing to state, not value changes yet.');
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
      if (!Number.isSafeInteger(fact.amount) || fact.amount < 0 || !fact.value_name) invalid('Unsupported START value.');
    } else if (fact.relation === 'is') {
      if (!fact.value || fact.value.kind !== 'state' || !fact.value.name) invalid('Unsupported START state.');
    } else invalid('Unsupported START relation.');
  }
  for (const evt of ir.events) {
    if (!evt.when) invalid('Invalid WHEN event.');
    checkReference(evt.when.actor, known, 'WHEN actor');
    checkReference(evt.when.target, known, 'WHEN target');
    if (!evt.when.action || !Array.isArray(evt.then) || !evt.then.length) invalid('WHEN must have an event and at least one action.');
    evt.then.forEach(action => checkAction(action, known));
  }
  for (const rule of ir.if_rules) {
    checkCondition(rule.if, known);
    if (!Array.isArray(rule.then) || !rule.then.length) invalid('IF needs at least one action.');
    rule.then.forEach(action => checkAction(action, known));
    if (Object.hasOwn(rule, 'otherwise')) {
      if (!Array.isArray(rule.otherwise) || !rule.otherwise.length) invalid('OTHERWISE needs at least one action.');
      rule.otherwise.forEach(action => checkAction(action, known));
    }
  }
}

export class BSharpSandbox {
  constructor(ir) {
    validate(ir);
    this.ir = clone(ir);
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
    this.active = this.ir.if_rules.map(rule => Object.hasOwn(rule, 'otherwise') ? null : false);
    for (const fact of this.ir.facts) {
      const thing = this.objects.get(fact.subject.name);
      if (fact.relation === 'has') {
        thing.values[fact.value_name] = fact.amount;
        this.trace.push('START: ' + thing.name + ' has ' + fact.amount + ' ' + fact.value_name);
      } else {
        this.setState(thing, fact.value.name);
        this.trace.push('START: ' + thing.name + ' is ' + fact.value.name);
      }
    }
    this.trace.push('START finished.');
    this.settle('START');
    return this.snapshot();
  }
  snapshot() {
    return [...this.objects.values()].map(thing => ({
      name: thing.name, kind: thing.kind, builtin: thing.builtin,
      states: [...thing.states].sort(), relations: {...thing.relations},
      values: {...thing.values}
    }));
  }
  eventOptions() {
    return this.ir.events.map((rule, index) => ({
      index, label: display(rule.when.actor) + ' ' + rule.when.action + ' ' + display(rule.when.target)
    }));
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
    if (rule.relation === 'has') return thing.values[rule.value_name] === rule.amount;
    invalid('The requested IF comparison is not implemented.');
  }
  apply(action) {
    const thing = this.objects.get(action.target.name), word = action.action;
    if (word === 'change') {
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
      thing.relations['carried by'] = 'player';
      delete thing.relations.in; delete thing.relations.on;
      this.trace.push('(carry ' + thing.name + ' → carried by player');
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
  runEvent(index) {
    if (!Number.isInteger(index) || index < 0 || index >= this.ir.events.length) invalid('Choose a listed WHEN event.');
    const rule = this.ir.events[index];
    const name = display(rule.when.actor) + ' ' + rule.when.action + ' ' + display(rule.when.target);
    this.trace.push('EVENT: ' + name);
    for (const action of rule.then) this.apply(action);
    this.settle('event');
    return this.snapshot();
  }
}
