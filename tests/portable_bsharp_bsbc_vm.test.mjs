// Source-only future regression definitions for BASIC# portable BSBC Profile 1 VM.
// NOT RUN during GitHub-only development. No Ruby dependency.
import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto} from 'node:crypto';
import {compile} from '../compiler/portable/bsharp_compiler.mjs';
import {encodeProfile1,BSBCEncodeError} from '../compiler/portable/bsharp_bsbc_encoder.mjs';
import {BSBCLoadError} from '../compiler/portable/bsharp_bsbc_loader.mjs';
import {BSharpBytecodeVM,BSBCVMError} from '../compiler/portable/bsharp_bsbc_vm.mjs';

if(!globalThis.crypto?.subtle)globalThis.crypto=webcrypto;
async function vmFor(source) {
  const artifact=await encodeProfile1(compile(source));
  return new BSharpBytecodeVM(artifact.bytes,{expectedFingerprint:artifact.fingerprint});
}
const worldThing=(vm,name)=>vm.snapshot().find(thing=>thing.name===name);
const source=lines=>lines.join('\n');
const intro=source([
  'DEFINE','[',' @lamp is a #device',' @switch is a #device','].',
  'START','[',' @lamp is off',' PLAYER has 6 health','].',
  'WHEN PLAYER attacks @switch','[',' |then (change @lamp to on','].',
  'WHEN PLAYER speaks @switch','[',' |then (change @lamp to off','].',
  'IF @lamp is on','[',' |then (damage PLAYER by 2','].'
]);
test('VM only accepts real validated binary bytes, not BSIR or a forged model',()=>{
  assert.throws(()=>new BSharpBytecodeVM({events:[]}),BSBCLoadError);
  assert.throws(()=>new BSharpBytecodeVM(new Uint8Array([66,83,66,67])),BSBCLoadError);
});
test('real BSBC START, WHEN, IF, state opposites and damage change the world',async()=>{
  const vm=await vmFor(intro);
  assert.deepEqual(worldThing(vm,'lamp').states,['off']);
  assert.equal(worldThing(vm,'player').values.health,6);
  assert.equal(worldThing(vm,'player').values.damage,0);
  vm.runEventText('PLAYER attacks @switch');
  assert.deepEqual(worldThing(vm,'lamp').states,['on']);
  assert.equal(worldThing(vm,'player').values.damage,2);
  vm.runEventText('PLAYER attacks @switch');
  assert.equal(worldThing(vm,'player').values.damage,2);
  vm.runEventText('PLAYER speaks @switch');
  vm.runEventText('PLAYER attacks @switch');
  assert.equal(worldThing(vm,'player').values.damage,4);
  vm.reset();
  assert.deepEqual(worldThing(vm,'lamp').states,['off']);
  assert.equal(worldThing(vm,'player').values.damage,0);
});
test('VM provides concrete, clickable WHEN choices using binary event records',async()=>{
  const vm=await vmFor(intro);
  const choices=vm.eventOptions();
  const option=choices.find(row=>row.actor==='player'&&row.target==='switch'&&row.label.includes('attacks'));
  assert(option);
  vm.runEvent(option.index,option);
  assert.deepEqual(worldThing(vm,'lamp').states,['on']);
});
test('VM rejects nonmatching events with no invented side effects',async()=>{
  const vm=await vmFor(intro);
  assert.throws(()=>vm.runEventText('PLAYER attacks @lamp'),BSBCVMError);
  assert.throws(()=>vm.runEventText('PLAYER attacks @stranger'),BSBCVMError);
  assert.deepEqual(worldThing(vm,'lamp').states,['off']);
});
test('VM evaluates whole-number equality and numeric assignments',async()=>{
  const s=source([
    'DEFINE','[',' @coin is a #thing','].',
    'START','[',' PLAYER has 0 score',' PLAYER has 0 victories','].',
    'WHEN PLAYER takes @coin','[',' |then (change score of PLAYER to 10','].',
    'IF PLAYER has 10 score','[',' |then (change victories of PLAYER to 1','].'
  ]);
  const vm=await vmFor(s);
  vm.runEventText('PLAYER takes @coin');
  assert.equal(worldThing(vm,'player').values.score,10);
  assert.equal(worldThing(vm,'player').values.victories,1);
});
test('VM refuses numeric assignment without established START value',async()=>{
  const s=source([
    'DEFINE','[',' @coin is a #thing','].',
    'WHEN PLAYER takes @coin','[',' |then (change score of PLAYER to 10','].'
  ]);
  const vm=await vmFor(s);
  assert.throws(()=>vm.runEventText('PLAYER takes @coin'),BSBCVMError);
  assert.equal(worldThing(vm,'player').values.score,undefined);
});
test('VM executes CARRY and UNLOCK instructions from binary, not source text',async()=>{
  const s=source([
    'DEFINE','[',' @door is a #door',' @key is a #key','].',
    'START','[',' @door is locked','].',
    'WHEN PLAYER takes @key','[',' |then (carry @key',' |then (unlock @door','].'
  ]);
  const vm=await vmFor(s);
  vm.runEventText('PLAYER takes @key');
  assert.equal(worldThing(vm,'key').relations['carried by'],'player');
  assert.deepEqual(worldThing(vm,'door').states,['unlocked']);
});
test('VM matches inherited #Kinds and binds it to the selected object',async()=>{
  const s=source([
    'KINDS','[',' #monster is a #creature','].',
    'DEFINE','[',' @goblin is a #monster',' @wolf is a #creature',' @door is a #door','].',
    'WHEN PLAYER attacks a #creature','[',' |then (damage it by 2','].'
  ]);
  const vm=await vmFor(s);
  const choices=vm.eventOptions();
  assert(choices.some(e=>e.target==='goblin'));
  assert(choices.some(e=>e.target==='wolf'));
  assert(!choices.some(e=>e.target==='door'));
  vm.runEventText('PLAYER attacks @goblin');
  vm.runEventText('PLAYER attacks @wolf');
  assert.equal(worldThing(vm,'goblin').values.damage,2);
  assert.equal(worldThing(vm,'wolf').values.damage,2);
  assert.equal(worldThing(vm,'door').values.damage,0);
});
test('VM prefers specific named WHEN rules over generic Kind rules',async()=>{
  const s=source([
    'DEFINE','[',' @goblin is a #creature',' @wolf is a #creature','].',
    'WHEN PLAYER attacks a #creature','[',' |then (damage it by 2','].',
    'WHEN PLAYER attacks @goblin','[',' |then (damage @goblin by 5','].'
  ]);
  const vm=await vmFor(s);
  const goblins=vm.eventOptions().filter(e=>e.target==='goblin'&&e.action!=='speaks');
  assert.equal(goblins.length,1);
  vm.runEventText('PLAYER attacks @goblin');
  vm.runEventText('PLAYER attacks @wolf');
  assert.equal(worldThing(vm,'goblin').values.damage,5);
  assert.equal(worldThing(vm,'wolf').values.damage,2);
});
test('every #Kind applies actions to inherited and direct members only',async()=>{
  const s=source([
    'KINDS','[',' #soldier is a #guard','].',
    'DEFINE','[',' @one is a #soldier',' @two is a #guard',' @door is a #door','].',
    'START','[',' @one is calm',' @two is calm',' @door is closed','].',
    'WHEN PLAYER opens @door','[',' |then (change every #guard to angry','].'
  ]);
  const vm=await vmFor(s);
  vm.runEventText('PLAYER opens @door');
  assert.deepEqual(worldThing(vm,'one').states,['angry']);
  assert.deepEqual(worldThing(vm,'two').states,['angry']);
  assert.deepEqual(worldThing(vm,'door').states,['closed']);
});
test('caused events process FIFO and settle IF rules after each matched event',async()=>{
  const s=source([
    'DEFINE','[',' @bell is a #device',' @door is a #door',' @guard is a #guard','].',
    'START','[',' @door is locked','].',
    'WHEN PLAYER sounds @bell','[',
    ' |then (cause @guard opens @door',' |then (change @door to closed','].',
    'WHEN @guard opens @door','[',
    ' |then (open @door',' |then (cause @guard attacks PLAYER','].',
    'WHEN @guard attacks PLAYER','[',' |then (damage PLAYER by 3','].'
  ]);
  const vm=await vmFor(s);
  vm.runEventText('PLAYER sounds @bell');
  assert.deepEqual(worldThing(vm,'door').states,['open']);
  assert.equal(worldThing(vm,'player').values.damage,3);
  assert.deepEqual(vm.trace.filter(x=>x.startsWith('EVENT (BSBC):')).map(x=>x.slice(14)),[
    'player sound bell','guard open door','guard attack player'
  ]);
});
test('self-causing events stop with a bounded loop error',async()=>{
  const s=source([
    'DEFINE','[',' @bell is a #device','].',
    'WHEN PLAYER sounds @bell','[',' |then (cause PLAYER sounds @bell','].'
  ]);
  const vm=await vmFor(s);
  assert.throws(()=>vm.runEventText('PLAYER sounds @bell'),/64 follow-ups/);
});
test('text and higher-profile programs never silently fall back to BSIR',async()=>{
  const s=source([
    'DEFINE','[',' @door is a #door','].',
    'START','[',' @door has "Closed" title','].'
  ]);
  await assert.rejects(encodeProfile1(compile(s)),BSBCEncodeError);
});
test('modified binary does not load with original trusted fingerprint',async()=>{
  const out=await encodeProfile1(compile(intro));
  const forged=out.bytes.slice();
  // META is the third section in the canonical eight-entry directory.
  const metaOffset=new DataView(forged.buffer).getUint32(32+16+4,true);
  forged[metaOffset+12]^=1;
  assert.throws(()=>new BSharpBytecodeVM(forged,{expectedFingerprint:out.fingerprint}),BSBCLoadError);
});
