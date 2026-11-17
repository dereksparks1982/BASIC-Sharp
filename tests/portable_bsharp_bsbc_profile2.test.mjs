// Future regression definitions for independent BSBC Profile 2 text support.
// Unexecuted until the owner authorizes tests. No Ruby, downloads or installs.
import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto} from 'node:crypto';
import {compile} from '../compiler/portable/bsharp_compiler.mjs';
import {encodeBSBC,encodeProfile1,encodeProfile2,BSBCEncodeError} from '../compiler/portable/bsharp_bsbc_encoder.mjs';
import {loadBSBC,loadProfile1,loadProfile2,BSBCLoadError} from '../compiler/portable/bsharp_bsbc_loader.mjs';
import {BSharpBytecodeVM,BSBCVMError} from '../compiler/portable/bsharp_bsbc_vm.mjs';
if(!globalThis.crypto?.subtle)globalThis.crypto=webcrypto;

const program=lines=>lines.join('\n');
const P2=program([
  'DEFINE','[',' @gate is a #door',' @bell is a #device','].',
  'START','[',' @gate has "North  Gate" title',' @gate is closed','].',
  'WHEN PLAYER sounds @bell','[',' |then (change title of @gate to "Open — Welcome!"','].',
  'WHEN PLAYER opens @gate','[',' |then (change title of @gate to "North  Gate"','].',
  'IF @gate has "Open — Welcome!" title','[',' |then (change @gate to open','].'
]);
async function artifactOf(source=P2) {
  return encodeBSBC(compile(source));
}
const worldThing=(vm,name)=>vm.snapshot().find(x=>x.name===name);
const set32=(bytes,offset,value)=>new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength).setUint32(offset,value,true);
const u32=(bytes,offset)=>new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength).getUint32(offset,true);
const section=(bytes,name)=>{
  for(let i=0;i<8;i++){
    const at=32+i*16;
    if(String.fromCharCode(...bytes.subarray(at,at+4))===name)
      return {offset:u32(bytes,at+4),length:u32(bytes,at+8),count:u32(bytes,at+12)};
  }
  throw Error('Missing section '+name);
};
test('Profile 2 is selected from actual text meaning without Ruby',async()=>{
  const ir=compile(P2);
  assert.equal(ir.meaning_profile,'bsharp.meaning.v2');
  const emitted=await encodeBSBC(ir);
  assert.equal(emitted.profile,'bsharp.bytecode.v2');
  assert.equal(emitted.meaningProfile,'bsharp.meaning.v2');
  assert.equal(new DataView(emitted.bytes.buffer).getUint16(6,true),2);
  assert.deepEqual(emitted.sections.map(x=>x.id),['STRS','META','KIND','THNG','STRT','EVNT','IFRL','CODE']);
});
test('Profile 2 preserves punctuation, case and double interior spaces',async()=>{
  const output=await artifactOf();
  const decoded=loadProfile2(output.bytes,{expectedFingerprint:output.fingerprint});
  assert(decoded.strings.includes('North  Gate'));
  assert(decoded.strings.includes('Open — Welcome!'));
  assert.equal(decoded.startRecords.find(x=>x.name==='START_TEXT_VALUE').name,'START_TEXT_VALUE');
  assert(decoded.blocks.flatMap(x=>x.instructions).some(x=>x.name==='CHANGE_TEXT_VALUE'));
  assert(decoded.ifRules.some(x=>x.condition.name==='TEXT_VALUE_EQUALS'));
});
test('real Profile 2 binary VM executes text changes and reactive text IF',async()=>{
  const out=await artifactOf();
  const vm=new BSharpBytecodeVM(out.bytes,{expectedFingerprint:out.fingerprint});
  assert.equal(worldThing(vm,'gate').values.title,'North  Gate');
  assert.deepEqual(worldThing(vm,'gate').states,['closed']);
  vm.runEventText('PLAYER sounds @bell');
  assert.equal(worldThing(vm,'gate').values.title,'Open — Welcome!');
  assert.deepEqual(worldThing(vm,'gate').states,['open']);
  vm.runEventText('PLAYER opens @gate');
  assert.equal(worldThing(vm,'gate').values.title,'North  Gate');
  vm.reset();
  assert.equal(worldThing(vm,'gate').values.title,'North  Gate');
});
test('text equality is case and whitespace sensitive',async()=>{
  const changed=P2.replace('IF @gate has "Open — Welcome!" title','IF @gate has "open — Welcome!" title');
  const out=await artifactOf(changed);
  const vm=new BSharpBytecodeVM(out.bytes,{expectedFingerprint:out.fingerprint});
  vm.runEventText('PLAYER sounds @bell');
  assert.equal(worldThing(vm,'gate').values.title,'Open — Welcome!');
  assert.deepEqual(worldThing(vm,'gate').states,['closed']);
});
test('Profile 2 can update every Thing in a matched inherited Kind',async()=>{
  const source=program([
    'KINDS','[',' #panel is a #device','].',
    'DEFINE','[',' @first is a #panel',' @second is a #device',' @bell is a #door','].',
    'START','[',' @first has "sleep" label',' @second has "sleep" label','].',
    'WHEN PLAYER opens @bell','[',' |then (change label of every #device to "READY!"','].'
  ]);
  const out=await artifactOf(source);
  const vm=new BSharpBytecodeVM(out.bytes,{expectedFingerprint:out.fingerprint});
  vm.runEventText('PLAYER opens @bell');
  assert.equal(worldThing(vm,'first').values.label,'READY!');
  assert.equal(worldThing(vm,'second').values.label,'READY!');
  assert.equal(worldThing(vm,'bell').values.label,undefined);
});
test('Profile 1 encoding and strict loader behavior remain separately available',async()=>{
  const original=program([
    'DEFINE','[',' @lamp is a #device','].',
    'START','[',' @lamp is off','].',
    'WHEN PLAYER attacks @lamp','[',' |then (change @lamp to on','].'
  ]);
  const ir=compile(original);
  const a=await encodeBSBC(ir),b=await encodeProfile1(ir);
  assert.deepEqual([...a.bytes],[...b.bytes]);
  assert.equal(loadProfile1(a.bytes).profile,'bsharp.bytecode.v1');
  assert.throws(()=>loadProfile2(a.bytes),BSBCLoadError);
  assert.throws(()=>loadProfile1((await artifactOf()).bytes),BSBCLoadError);
});
test('explicit Profile 1 emitter rejects Profile 2 meaning',async()=>{
  await assert.rejects(encodeProfile1(compile(P2)),BSBCEncodeError);
});
test('explicit Profile 2 emitter rejects programs with no text features',async()=>{
  const src=program(['DEFINE','[',' @lamp is a #device','].',
    'WHEN PLAYER opens @lamp','[',' |then (open @lamp','].']);
  await assert.rejects(encodeProfile2(compile(src)),BSBCEncodeError);
});
test('broken Profile 2 text string index is rejected by strict loader',async()=>{
  const out=await artifactOf(),bytes=out.bytes.slice();
  const start=section(bytes,'STRT');
  const pos=start.offset;
  assert.equal(bytes[pos],0x13);
  set32(bytes,pos+12,0xffffffff);
  assert.throws(()=>loadBSBC(bytes),BSBCLoadError);
});
test('text opcodes embedded under a forged Profile 1 header are rejected',async()=>{
  const out=await artifactOf(),bytes=out.bytes.slice();
  bytes[6]=1;
  assert.throws(()=>loadBSBC(bytes),BSBCLoadError);
});
test('unsupported text escapes, interpolations and multiline literal payloads cannot be emitted',async()=>{
  for(const value of ['bad\\escape','#{injected}','has\nnewline']) {
    const ir=compile(P2);
    ir.facts[0].text_value=value;
    await assert.rejects(encodeBSBC(ir),BSBCEncodeError);
  }
});
test('binary loader rejects text/number value-name type conflict',async()=>{
  const ir=compile(P2);
  const condition=ir.if_rules[0].if;
  delete condition.text_value;
  condition.amount=0;
  await assert.rejects(encodeBSBC(ir),BSBCEncodeError);
});
test('unknown higher meaning profile never silently falls back to Profile 2',async()=>{
  const ir=compile(P2);
  ir.meaning_profile='bsharp.meaning.v3';
  await assert.rejects(encodeBSBC(ir),BSBCEncodeError);
});
test('Profile 2 untrusted bytes do not replace a trusted source fingerprint',async()=>{
  const out=await artifactOf();
  const modified=out.bytes.slice();
  const meta=section(modified,'META');
  modified[meta.offset+12]^=1;
  assert.throws(()=>loadProfile2(modified,{expectedFingerprint:out.fingerprint}),BSBCLoadError);
});
