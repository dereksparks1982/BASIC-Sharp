// BASIC# portable source -> BSIR compiler. Unaccepted v0.0.85 development candidate.
// Ruby is not invoked. Creator syntax and meaning profiles 1-7 are preserved.
// This is a bounded subset; unsupported features must fail, not produce fake success.
export class BSharpError extends Error {
  constructor(line, message) {
    super('Line ' + line + ': ' + message);
    this.name = 'BSharpError';
    this.line = line;
  }
}
const fail = (line, message) => { throw new BSharpError(line, message); };
const norm = value => value.trim().replace(/\s+/gu, ' ').toLowerCase();
const MAX = 2147483647;
const HEADS = new Set(['KINDS','DEFINE','START','WHEN','IF','OTHERWISE','CONTROLS','HOVER','CONTEXT']);
const BUILTIN = new Set(['thing','place','actor','person','creature','door','container','supporter',
  'key','weapon','food','clothing','device','guard','table']);
const STATES = new Set(['open','closed','locked','unlocked','alive','dead','calm','angry','friendly',
  'hostile','visible','hidden','carried','dropped','broken','whole','on','off']);
const ACTIONS = new Set(['take','drop','carry','open','close','lock','unlock','attack','damage','change',
  'increase','decrease','speak','give','eat','wear','remove','sound','examine','cause']);
const EVENT = new Map([
  ...['take','drop','carry','open','close','lock','unlock','attack','damage','change',
    'increase','decrease','speak','give','eat','wear','remove','sound','examine'].map(verb => [verb,verb]),
  ['takes','take'],['drops','drop'],['carries','carry'],['opens','open'],['closes','close'],
  ['locks','lock'],['unlocks','unlock'],['attacks','attack'],['damages','damage'],
  ['changes','change'],['increases','increase'],['decreases','decrease'],
  ['speaks','speak'],['gives','give'],['eats','eat'],['wears','wear'],
  ['removes','remove'],['sounds','sound'],['examines','examine']
]);
const VALUE = /^[a-z][a-z0-9]*$/u;
function number(text, line, minimum = 0) {
  if (!/^\d+$/u.test(text)) fail(line, 'A number must use whole digits without commas or decimals.');
  const value = Number(text);
  if (!Number.isSafeInteger(value) || value < minimum || value > MAX) {
    fail(line, 'A number must be between ' + minimum + ' and ' + MAX + '.');
  }
  return value;
}
function valueName(text, line) {
  const result = norm(text);
  if (!VALUE.test(result)) fail(line, 'A value name must be one plain word, such as health or score.');
  return result;
}
function textLiteral(source, line) {
  if (!/^"[^"]*"$/u.test(source)) {
    fail(line, 'A text value must use exactly one pair of double quotes.');
  }
  return source.slice(1, -1);
}
// Preserve line numbers when removing // ... /. comments, ignoring markers in quotes.
export function read(source) {
  if (typeof source !== 'string') throw new TypeError('BASIC# source must be text.');
  let output = '', comment = false, quoted = false, line = 1, commentLine = 0, quotedLine = 0;
  for (let i = 0; i < source.length; i++) {
    const ch = source[i], pair = source.slice(i, i + 2);
    if (comment) {
      if (pair === '//') fail(line, 'A comment cannot begin inside another comment.');
      if (pair === '/.') { comment = false; output += '  '; i++; continue; }
      output += ch === '\n' ? '\n' : ' ';
      if (ch === '\n') line++;
      continue;
    }
    if (!quoted && pair === '/.') fail(line, 'Found /. without an opening // comment.');
    if (!quoted && pair === '//') {
      comment = true; commentLine = line; output += '  '; i++; continue;
    }
    if (ch === '"') { quoted = !quoted; if (quoted) quotedLine = line; }
    if (ch === '\n') {
      if (quoted) fail(quotedLine, 'Text values cannot span multiple lines.');
      line++;
    }
    output += ch;
  }
  if (quoted) fail(quotedLine, 'A text value is missing its closing quote.');
  if (comment) fail(commentLine, 'The // comment needs a closing /.');
  return output.split(/\r?\n/u).map((text, index) => ({line:index + 1, text:text.trim()})).filter(row => row.text);
}
export function blocks(source) {
  const result = [];
  let active = null, opening = false;
  for (const row of read(source)) {
    if (!active) {
      const match = /^([A-Z]+)(?:\s+(.+))?$/u.exec(row.text);
      if (!match || !HEADS.has(match[1])) fail(row.line, 'Expected a BASIC# Head such as DEFINE, WHEN or IF.');
      if (['KINDS','DEFINE','START','OTHERWISE'].includes(match[1]) && match[2]) {
        fail(row.line, match[1] + ' cannot have extra words on its Head line.');
      }
      if (['WHEN','IF','CONTROLS','HOVER','CONTEXT'].includes(match[1]) && !match[2]) {
        fail(row.line, match[1] + ' requires a description on its Head line.');
      }
      active = {head:match[1], detail:match[2] || '', line:row.line, body:[]};
      opening = true;
      continue;
    }
    if (opening) {
      if (row.text !== '[') fail(row.line, active.head + ' needs [ on the next line.');
      opening = false;
      continue;
    }
    if (row.text === '].') { result.push(active); active = null; continue; }
    if (row.text === ']') fail(row.line, 'Close a BASIC# Body with ].');
    if (row.text === '[' || /^(?:KINDS|DEFINE|START|WHEN|IF|OTHERWISE|CONTROLS|HOVER|CONTEXT)(?:\s|$)/u.test(row.text)) {
      fail(row.line, 'Unexpected start of a new Body before the previous ].');
    }
    active.body.push(row);
  }
  if (active) fail(active.line, active.head + ' needs a closing ].');
  return result;
}
function contextFor(kinds, objects) { return {kinds, objects}; }
function reference(input, context, line) {
  const shown = input.trim(), key = norm(shown);
  if (shown === 'PLAYER') return {type:'object',text:'player',name:'player',object_kind:'person'};
  if (key === 'player') fail(line, 'The built-in player must be written as PLAYER.');
  if (shown.startsWith('@')) {
    const name = norm(shown.slice(1)), item = context.objects.get(name);
    if (!item) fail(line, 'Unknown Thing @' + name + '. Declare it in DEFINE.');
    return {type:'object',text:name,name,object_kind:item.kind};
  }
  // A unique definite Kind reference is resolved deterministically at compile time.
  const definite = /^the\s+#(.+)$/iu.exec(shown);
  if (definite) {
    const kind = norm(definite[1]);
    if (!context.kinds.has(kind)) fail(line, 'Unknown Kind #' + kind + '.');
    const match = [...context.objects.values()].filter(object => {
      let current = object.kind, visited = new Set();
      while (current && !visited.has(current)) {
        if (current === kind) return true;
        visited.add(current);
        current = context.kinds.get(current) || null;
      }
      return false;
    });
    if (match.length !== 1) fail(line, 'the #' + kind + ' must identify exactly one Thing; found ' + match.length + '. Use @name instead.');
    return {type:'object',text:'the '+kind,name:match[0].name,
      object_kind:match[0].kind,matched_by_kind:true};
  }
  if (/^(?:every|an?|that)\s+#/iu.test(shown) || shown.startsWith('#') || key === 'it') {
    fail(line, 'This compiler does not yet support ' + shown + ' here. Use a defined @Thing or a unique the #Kind.');
  }
  fail(line, 'Unknown reference "' + shown + '". Use @Thing, PLAYER, or a unique the #Kind.');
}
const semanticRaw = s => s.replace(/@(?=[a-z])/giu, '').replace(/#(?=[a-z])/giu, '').replace(/\bPLAYER\b/gu, 'player').trim();
function state(input, line) {
  const name = norm(input);
  if (!STATES.has(name)) fail(line, 'Unknown state "' + input.trim() + '".');
  return {kind:'state', name};
}
function fact(text, context, line, isCondition = false) {
  let match = /^(.+?)\s+has\s+("[^"]*")\s+([a-z][a-z0-9]*)$/iu.exec(text);
  if (match) {
    const subject = reference(match[1], context, line), value_name = valueName(match[3], line);
    if (value_name === 'damage') fail(line, 'Damage is a whole-number value and cannot store text.');
    const data = {subject,relation:'has',value_name,text_value:textLiteral(match[2], line)};
    return isCondition ? {raw:semanticRaw(text),...data}
      : {line_number:line,...data,raw:{subject:semanticRaw(match[1]),relation:'has',
          value:match[2]+' '+value_name,line_number:line}};
  }
  match = /^(.+?)\s+has\s+(?:(at least|more than|at most|less than)\s+)?(\d+)\s+([a-z][a-z0-9]*)$/iu.exec(text);
  if (match) {
    if (!isCondition && match[2]) fail(line, 'Threshold comparisons belong in IF, not START.');
    const subject = reference(match[1], context, line), amount = number(match[3], line);
    const value_name = valueName(match[4], line);
    const data = {subject,relation:'has',value_name,amount};
    if (isCondition && match[2]) data.comparison = {
      'at least':'at_least','more than':'more_than','at most':'at_most','less than':'less_than'
    }[norm(match[2])];
    return isCondition ? {raw:semanticRaw(text),...data}
      : {line_number:line,...data,raw:{subject:semanticRaw(match[1]),relation:'has',
          value:match[3]+' '+value_name,line_number:line}};
  }
  match = /^(.+?)\s+(is|isnt)\s+([a-z][a-z0-9 -]*)$/iu.exec(text);
  if (match) {
    if (!isCondition && norm(match[2]) === 'isnt') fail(line, 'START uses is, not isnt.');
    const subject = reference(match[1], context, line);
    const data = {subject,relation:norm(match[2]),value:state(match[3], line)};
    return isCondition ? {raw:semanticRaw(text),...data}
      : {line_number:line,...data,raw:{subject:semanticRaw(match[1]),relation:'is',
          value:norm(match[3]),line_number:line}};
  }
  fail(line, 'Expected @Thing is state, PLAYER has 3 health, or @Thing has "text" title.');
}
export function parseCondition(input, contextOrObjects, line) {
  // Accept a Map in standalone regression checks as well as the full context.
  const context = contextOrObjects instanceof Map
    ? contextFor(new Map([...BUILTIN].map(kind => [kind,null])),contextOrObjects)
    : contextOrObjects;
  let quote = false, start = 0;
  const clauses = [], connectors = [];
  for (let i = 0; i < input.length; i++) {
    if (input[i] === '"') quote = !quote;
    if (quote) continue;
    const match = /^(and|or)(?=\s|$)/iu.exec(input.slice(i));
    if (match && (i === 0 || /\s/u.test(input[i-1]))) {
      clauses.push(input.slice(start,i).trim()); connectors.push(norm(match[1]));
      i += match[1].length - 1; start = i + 1;
    }
  }
  clauses.push(input.slice(start).trim());
  if (clauses.some(clause => !clause)) fail(line, 'Every and/or needs a condition on both sides.');
  if (new Set(connectors).size > 1) fail(line, 'Do not mix and and or in one IF. Use separate IF rules.');
  const parsed = clauses.map(clause => fact(clause,context,line,true));
  return connectors.length
    ? {raw:parsed.map(item => item.raw).join(' '+connectors[0]+' '),connector:connectors[0],clauses:parsed}
    : parsed[0];
}
function action(text, context, line) {
  const match = /^\|then\s+\(([a-z]+)\s+(.+)$/iu.exec(text);
  if (!match) fail(line, 'Every action needs |then ( followed by an official action word.');
  const word = norm(match[1]), rest = match[2].trim();
  if (!ACTIONS.has(word)) fail(line, 'Unknown BASIC# action (' + word + '.');
  if (word === 'change') {
    let change = /^([a-z][a-z0-9]*)\s+of\s+(.+?)\s+to\s+("[^"]*")$/iu.exec(rest);
    if (change) {
      const value_name = valueName(change[1],line);
      if (value_name === 'damage') fail(line, 'Damage cannot store text.');
      return {line_number:line,action:'change',value_name,
        target:reference(change[2],context,line),to_text:textLiteral(change[3],line)};
    }
    change = /^([a-z][a-z0-9]*)\s+of\s+(.+?)\s+to\s+(\d+)$/iu.exec(rest);
    if (change) {
      return {line_number:line,action:'change',value_name:valueName(change[1],line),
        target:reference(change[2],context,line),to_amount:number(change[3],line)};
    }
    change = /^(.+?)\s+to\s+([a-z][a-z0-9 -]*)$/iu.exec(rest);
    if (!change) fail(line, 'Use (change @Thing to state, or (change title of @Thing to "text".');
    return {line_number:line,action:'change',target:reference(change[1],context,line),to:state(change[2],line)};
  }
  if (word === 'increase' || word === 'decrease') {
    const change = /^([a-z][a-z0-9]*)\s+of\s+(.+?)\s+by\s+(\d+)$/iu.exec(rest);
    if (!change) fail(line, 'Use ('+word+' score of PLAYER by 1.');
    return {line_number:line,action:word,value_name:valueName(change[1],line),
      target:reference(change[2],context,line),amount:number(change[3],line,1)};
  }
  if (word === 'damage') {
    const damage = /^(.+?)(?:\s+by\s+(\d+))?$/iu.exec(rest);
    if (!damage) fail(line, 'Use (damage @Thing by 3.');
    return {line_number:line,action:'damage',target:reference(damage[1],context,line),
      amount:damage[2] ? number(damage[2],line,1) : 1};
  }
  if (word === 'cause') fail(line, '(cause is a valid BASIC# word, but caused-event expansion is not yet in this portable subset.');
  const target = reference(rest,context,line);
  // Mirror established plain-English object interaction lowering.
  if (word === 'take') return {line_number:line,action:'carry',target};
  const transitions = {open:'open',close:'closed',lock:'locked'};
  if (Object.hasOwn(transitions,word)) {
    return {line_number:line,action:'change',target,to:state(transitions[word],line)};
  }
  return {line_number:line,action:word,target};
}
function event(input, context, line) {
  const match = /^(.+?)\s+([a-z]+)\s+(.+)$/iu.exec(input);
  if (!match || !EVENT.has(norm(match[2]))) fail(line, 'WHEN needs a recognized event, such as WHEN PLAYER attacks @guard.');
  return {raw:semanticRaw(input),actor:reference(match[1],context,line),
    action:EVENT.get(norm(match[2])),target:reference(match[3],context,line)};
}
function eachCondition(condition, visit) {
  if (condition.connector) condition.clauses.forEach(clause => eachCondition(clause,visit));
  else visit(condition);
}
function profileFor(ir) {
  if (ir.if_rules.some(rule => Object.hasOwn(rule,'otherwise'))) return 7;
  if (ir.if_rules.some(rule => !!rule.if.connector)) return 6;
  const actions = [...ir.events.flatMap(event => event.then),
    ...ir.if_rules.flatMap(rule => [...rule.then,...(rule.otherwise || [])])];
  let comparison = false, textCondition = false;
  for (const rule of ir.if_rules) eachCondition(rule.if, condition => {
    comparison ||= !!condition.comparison;
    textCondition ||= Object.hasOwn(condition,'text_value');
  });
  if (comparison || actions.some(a => a.action === 'increase' || a.action === 'decrease')) return 5;
  if (textCondition || ir.facts.some(f => Object.hasOwn(f,'text_value')) ||
      actions.some(a => Object.hasOwn(a,'to_text'))) return 2;
  return 1;
}
function validateValueTypes(ir) {
  const types = new Map();
  const remember = (name, type, line) => {
    const existing = types.get(name);
    if (existing && existing !== type) {
      fail(line, 'Value "'+name+'" cannot be both text and a whole number.');
    }
    types.set(name,type);
  };
  for (const fact of ir.facts) if (fact.relation === 'has') {
    remember(fact.value_name, Object.hasOwn(fact,'text_value') ? 'text' : 'number',fact.line_number);
  }
  for (const event of ir.events) for (const act of event.then) {
    if (act.value_name) remember(act.value_name, Object.hasOwn(act,'to_text') ? 'text' : 'number',act.line_number);
  }
  for (const rule of ir.if_rules) {
    eachCondition(rule.if, condition => {
      if (condition.relation === 'has') {
        remember(condition.value_name,Object.hasOwn(condition,'text_value') ? 'text':'number',rule.line_number);
      }
    });
    for (const act of [...rule.then,...(rule.otherwise || [])]) {
      if (act.value_name) remember(act.value_name,Object.hasOwn(act,'to_text') ? 'text' : 'number',act.line_number);
    }
  }
}
export function compile(source, {version = '0.0.84'} = {}) {
  const sections = blocks(source);
  const kinds = [], kindsKnown = new Map([...BUILTIN].map(kind => [kind,null]));
  const player = {name:'player',kind:'person',builtin:true,line_number:null};
  const objects = [player], objectsKnown = new Map([['player',player]]);
  for (const block of sections.filter(b => b.head === 'KINDS')) for (const row of block.body) {
    const match = /^#(.+?)\s+is\s+an?\s+#(.+)$/iu.exec(row.text);
    if (!match) fail(row.line,'Use #dragon is a #creature to define a Kind.');
    const name = norm(match[1]), parent = norm(match[2]);
    if (!kindsKnown.has(parent)) fail(row.line,'Unknown parent Kind #' + parent + '.');
    if (kindsKnown.has(name)) fail(row.line,'Kind #' + name + ' is already defined.');
    kinds.push({name,parent,line_number:row.line}); kindsKnown.set(name,parent);
  }
  for (const block of sections.filter(b => b.head === 'DEFINE')) for (const row of block.body) {
    const match = /^@(.+?)\s+is\s+an?\s+#(.+)$/iu.exec(row.text);
    if (!match) fail(row.line,'Use @north gate is a #door to define a Thing.');
    const name = norm(match[1]), kind = norm(match[2]);
    if (!kindsKnown.has(kind)) fail(row.line,'Unknown Kind #' + kind + '.');
    if (objectsKnown.has(name)) fail(row.line,'Thing @' + name + ' is already defined.');
    const object = {name,kind,builtin:false,line_number:row.line};
    objects.push(object); objectsKnown.set(name,object);
  }
  const context = contextFor(kindsKnown,objectsKnown);
  const ir = {version,format:'bsir.debug.json',kinds,objects,facts:[],events:[],if_rules:[],
    controls:[],hover_declarations:[],context_declarations:[],diagnostics:[]};
  let previous = null;
  for (const block of sections) {
    if (block.head === 'KINDS' || block.head === 'DEFINE') { previous = null; continue; }
    if (block.head === 'START') {
      for (const row of block.body) ir.facts.push(fact(row.text,context,row.line));
      previous = null; continue;
    }
    if (block.head === 'WHEN') {
      const then = block.body.map(row => action(row.text,context,row.line));
      if (!then.length) fail(block.line,'WHEN needs at least one |then action.');
      ir.events.push({line_number:block.line,when:event(block.detail,context,block.line),then});
      previous = null; continue;
    }
    if (block.head === 'IF') {
      const condition = parseCondition(block.detail,context,block.line);
      const then = block.body.map(row => action(row.text,context,row.line));
      if (!then.length) fail(block.line,'IF needs at least one |then action.');
      previous = {line_number:block.line,if:condition,then};
      ir.if_rules.push(previous); continue;
    }
    if (block.head === 'OTHERWISE') {
      if (!previous) fail(block.line,'OTHERWISE must directly follow one IF and occur only once.');
      const otherwise = block.body.map(row => action(row.text,context,row.line));
      if (!otherwise.length) fail(block.line,'OTHERWISE needs at least one |then action.');
      previous.otherwise_line_number = block.line;
      previous.otherwise = otherwise;
      previous = null; continue;
    }
    fail(block.line,block.head+' is protected BASIC# syntax but is not yet supported in this independent compiler.');
  }
  validateValueTypes(ir);
  const profile = profileFor(ir);
  if (profile > 1) ir.meaning_profile = 'bsharp.meaning.v'+profile;
  return ir;
}
