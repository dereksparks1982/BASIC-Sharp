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
