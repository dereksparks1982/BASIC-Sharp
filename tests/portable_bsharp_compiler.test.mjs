// Source-only tests for the independent compiler. Not executed yet.
import test from 'node:test';
import assert from 'node:assert/strict';
import {compile,read,parseCondition,BSharpError} from '../compiler/portable/bsharp_compiler.mjs';
const sample='DEFINE\n[\n @lamp is a #thing\n @switch is a #thing\n].\nSTART\n[\n @lamp is off\n].\nWHEN PLAYER attacks @switch\n[\n |then (change @lamp to on\n].\nIF @lamp is off\n[\n |then (damage PLAYER\n].\n';
test('Ruby-free source produces objects, facts, events, and conditions',()=>{
 const ir=compile(sample);
 assert.equal(ir.objects.length,3);
 assert.equal(ir.facts[0].value.name,'off');
 assert.equal(ir.events[0].then[0].action,'change');
 assert.equal(ir.if_rules[0].if.relation,'is');
});
test('protected punctuation is mandatory',()=>{
 assert.throws(()=>compile(sample.replace('@lamp is a #thing','lamp is a thing')),BSharpError);
 assert.throws(()=>compile(sample.replace('|then (change','then change')),BSharpError);
});
test('comments preserve line numbers',()=>{
 const items=read('//hidden /.\nSTART\n[\n @lamp is off //comment /.\n].');
 assert.equal(items.find(x=>x.text==='@lamp is off').line,4);
});
test('and-or mixture fails closed',()=>{
 const objects=new Map([['lamp',{kind:'thing'}]]);
 assert.throws(()=>parseCondition('@lamp is on and @lamp is off or @lamp is open',objects,1),BSharpError);
});
test('OTHERWISE maps to meaning Profile 7',()=>{
 const source='DEFINE\n[\n @lamp is a #thing\n].\nIF @lamp is off\n[\n |then (damage PLAYER\n].\nOTHERWISE\n[\n |then (change @lamp to on\n].';
 assert.equal(compile(source).meaning_profile,'bsharp.meaning.v7');
});
test('unsupported controls do not pretend to compile',()=>{
 assert.throws(()=>compile('CONTROLS for PLAYER\n[\n W moves PLAYER north\n].'),BSharpError);
});

test('IF threshold comparisons preserve all four accepted comparison words',()=>{
 const program='DEFINE\n[\n @boss is a #creature\n].\nSTART\n[\n PLAYER has 2 health\n].\nIF PLAYER has at least 2 health\n[\n |then (damage @boss\n].\nIF PLAYER has more than 1 health\n[\n |then (damage @boss\n].\nIF PLAYER has at most 2 health\n[\n |then (damage @boss\n].\nIF PLAYER has less than 3 health\n[\n |then (damage @boss\n].';
 const ir=compile(program);
 assert.deepEqual(ir.if_rules.map(rule=>rule.if.comparison),['at_least','more_than','at_most','less_than']);
 assert.equal(ir.meaning_profile,'bsharp.meaning.v5');
});
test('Text values keep exact casing, spaces, and punctuation',()=>{
 const program='KINDS\n[\n #gate is a #door\n].\nDEFINE\n[\n @north gate is a #gate\n].\nSTART\n[\n @north gate has "North  Gate!" title\n].\nIF @north gate has "North  Gate!" title\n[\n |then (change title of the #gate to "OPEN — Welcome!"\n].';
 const ir=compile(program);
 assert.equal(ir.facts[0].text_value,'North  Gate!');
 assert.equal(ir.if_rules[0].if.text_value,'North  Gate!');
 assert.equal(ir.if_rules[0].then[0].to_text,'OPEN — Welcome!');
 assert.equal(ir.if_rules[0].then[0].target.name,'north gate');
 assert.equal(ir.meaning_profile,'bsharp.meaning.v2');
});
test('plain-English actions lower to established canonical BSharp IR actions',()=>{
 const program='DEFINE\n[\n @door is a #door\n @key is a #key\n].\nWHEN PLAYER takes @key\n[\n |then (take @key\n |then (open @door\n |then (close @door\n |then (lock @door\n].';
 const actions=compile(program).events[0].then;
 assert.deepEqual(actions.map(a=>a.action),['carry','change','change','change']);
 assert.deepEqual(actions.slice(1).map(a=>a.to.name),['open','closed','locked']);
});
test('ambiguous definite Kind references fail instead of selecting arbitrarily',()=>{
 const program='DEFINE\n[\n @east gate is a #door\n @west gate is a #door\n].\nWHEN PLAYER attacks @east gate\n[\n |then (open the #door\n].';
 assert.throws(()=>compile(program),BSharpError);
});
test('value names cannot change between text and whole-number types',()=>{
 const program='DEFINE\n[\n @gate is a #door\n].\nSTART\n[\n @gate has "Gate" title\n].\nIF @gate has 12 title\n[\n |then (damage PLAYER\n].';
 assert.throws(()=>compile(program),BSharpError);
});


test('WHEN accepts a #Kind and binds it to exactly one event-selected Thing',()=>{
 const source=[
  'KINDS','[',' #monster is a #creature','].',
  'DEFINE','[',' @goblin is a #monster',' @wolf is a #creature','].',
  'WHEN PLAYER attacks a #creature','[',' |then (damage it by 2','].'
 ].join('\n');
 const ir=compile(source);
 assert.equal(ir.events[0].when.target.type,'kind_one');
 assert.equal(ir.events[0].when.target.kind_name,'creature');
 assert.equal(ir.events[0].then[0].target.type,'previous');
 assert.equal(ir.events[0].then[0].target.kind_name,'creature');
});
test('WHEN names a single Thing and lets it refer back to that object',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature','].',
  'WHEN PLAYER speaks @goblin','[',' |then (damage it','].'
 ].join('\n');
 const ir=compile(source);
 assert.equal(ir.events[0].then[0].target.type,'object');
 assert.equal(ir.events[0].then[0].target.name,'goblin');
});
test('it outside an established event is rejected with no implicit global selection',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature','].',
  'IF @goblin is alive','[',' |then (damage it','].'
 ].join('\n');
 assert.throws(()=>compile(source),BSharpError);
});
test('it cannot guess between two specifically named event objects',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature',' @wolf is a #creature','].',
  'WHEN @goblin attacks @wolf','[',' |then (damage it','].'
 ].join('\n');
 assert.throws(()=>compile(source),BSharpError);
});
test('WHEN pattern rejects unsupported all-Kind selection without rewriting syntax',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature','].',
  'WHEN PLAYER attacks every #creature','[',' |then (damage @goblin','].'
 ].join('\n');
 assert.throws(()=>compile(source),BSharpError);
});


test('every #Kind is a deterministic BSIR action selector, not an IF or event selector',()=>{
  const source=[
    'KINDS','[',' #soldier is a #guard','].',
    'DEFINE','[',' @alice is a #soldier',' @bob is a #guard','].',
    'WHEN PLAYER attacks @alice','[',' |then (change every #guard to angry','].'
  ].join('\n');
  const result=compile(source);
  const target=result.events[0].then[0].target;
  assert.equal(target.type,'kind_set');
  assert.equal(target.kind_name,'guard');
  assert.deepEqual(target.candidates,['alice','bob']);
});
test('cause emits nested BSIR event data with selected it binding',()=>{
  const source=[
    'DEFINE','[',' @goblin is a #creature','].',
    'WHEN PLAYER attacks a #creature','[',
    ' |then (cause it attacks PLAYER','].'
  ].join('\n');
  const action=compile(source).events[0].then[0];
  assert.equal(action.action,'cause');
  assert.equal(action.event.actor.type,'previous');
  assert.equal(action.event.actor.kind_name,'creature');
  assert.equal(action.event.target.name,'player');
  assert.equal(action.event.action,'attack');
});
test('cause cannot invent an unbound a #Kind target or use every #Kind as an event actor',()=>{
  const s=[
    'DEFINE','[',' @goblin is a #creature',' @door is a #door','].',
    'WHEN PLAYER attacks @door','[',
    ' |then (cause every #creature attacks @goblin','].'
  ].join('\n');
  assert.throws(()=>compile(s),BSharpError);
});
test('every #Kind is not allowed as a START or IF subject',()=>{
  const s=[
    'DEFINE','[',' @goblin is a #creature','].',
    'IF every #creature is alive','[',' |then (damage @goblin','].'
  ].join('\n');
  assert.throws(()=>compile(s),BSharpError);
});
test('a chain cannot bypass referenced Thing name validation',()=>{
  const s=[
    'DEFINE','[',' @goblin is a #creature','].',
    'WHEN PLAYER attacks @goblin','[',' |then (cause @unknown attacks PLAYER','].'
  ].join('\n');
  assert.throws(()=>compile(s),BSharpError);
});
