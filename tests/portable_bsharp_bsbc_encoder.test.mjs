// Regression definitions for the independent BSBC Profile 1 emitter.
// DO NOT run until owner explicitly resumes compilation and test execution.
import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto} from 'node:crypto';
import {compile} from '../compiler/portable/bsharp_compiler.mjs';
import {encodeProfile1,meaningFingerprint,BSBCEncodeError,hexView} from '../compiler/portable/bsharp_bsbc_encoder.mjs';

if(!globalThis.crypto?.subtle)globalThis.crypto=webcrypto;
const simple=[
  'DEFINE','[',' @lamp is a #device',' @switch is a #device','].',
  'START','[',' @lamp is off','].',
  'WHEN PLAYER attacks @switch','[',' |then (change @lamp to on','].',
  'IF @lamp is on','[',' |then (damage PLAYER','].'
].join('\n');
const u32=(bytes,offset)=>new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength).getUint32(offset,true);
const ascii=(bytes,start,length)=>new TextDecoder().decode(bytes.subarray(start,start+length));
function sections(bytes) {
  const result=[];
  for(let i=0;i<8;i++) {
    const start=32+i*16;
    result.push({id:ascii(bytes,start,4),offset:u32(bytes,start+4),
      length:u32(bytes,start+8),count:u32(bytes,start+12)});
  }
  return result;
}
test('BSBC output has the official Profile 1 header and all eight ordered sections',async()=>{
  const {bytes,sections:dir}=await encodeProfile1(compile(simple));
  assert.equal(ascii(bytes,0,4),'BSBC');
  assert.equal(new DataView(bytes.buffer).getUint16(4,true),1);
  assert.equal(new DataView(bytes.buffer).getUint16(6,true),1);
  assert.equal(u32(bytes,8),32);
  assert.equal(u32(bytes,12),8);
  assert.equal(u32(bytes,16),32);
  assert.equal(u32(bytes,20),16);
  assert.equal(u32(bytes,24),bytes.length);
  assert.equal(u32(bytes,28),0);
  assert.deepEqual(dir.map(s=>s.id),['STRS','META','KIND','THNG','STRT','EVNT','IFRL','CODE']);
  assert.deepEqual(sections(bytes),dir);
  for(let i=0;i<dir.length;i++){
    assert.equal(dir[i].offset%4,0);
    assert(dir[i].offset>=160);
    assert(dir[i].offset+dir[i].length<=bytes.length);
    if(i)assert(dir[i].offset>=dir[i-1].offset+dir[i-1].length);
  }
  assert.equal(dir.find(s=>s.id==='EVNT').count,1);
  assert.equal(dir.find(s=>s.id==='IFRL').count,1);
  assert.equal(dir.find(s=>s.id==='CODE').count,2);
});
test('the BSBC fingerprint is SHA-256 of canonical semantic IR, not source line numbers',async()=>{
  const a=compile(simple),b=compile('\n\n'+simple);
  const fingerprint=await meaningFingerprint(a);
  assert.equal(fingerprint.length,32);
  const emitted=await encodeProfile1(a);
  const meta=emitted.sections.find(s=>s.id==='META');
  assert.deepEqual([...emitted.bytes.slice(meta.offset+12,meta.offset+44)],[...fingerprint]);
  assert.deepEqual([...emitted.bytes],[...(await encodeProfile1(b)).bytes]);
});
test('Profile 1 sections include real instruction record opcodes and record sizes',async()=>{
  const bsbc=await encodeProfile1(compile(simple)),bytes=bsbc.bytes;
  const st=bsbc.sections.find(s=>s.id==='STRT');
  assert.equal(bytes[st.offset],0x10);
  assert.equal(bytes[st.offset+1],3);
  assert.equal(bytes[st.offset+2],0);
  assert.equal(bytes[st.offset+3],0);
  const code=bsbc.sections.find(s=>s.id==='CODE');
  assert.equal(u32(bytes,code.offset),2);
  const firstInstruction=code.offset+u32(bytes,code.offset+8);
  assert.equal(bytes[firstInstruction],0x21);
  const secondInstruction=code.offset+u32(bytes,code.offset+24);
  assert.equal(bytes[secondInstruction],0x20);
});
test('Kind-set actions and caused events encode official selectors and opcodes',async()=>{
  const source=[
    'DEFINE','[',' @goblin is a #creature',' @wolf is a #creature',' @bell is a #device','].',
    'WHEN PLAYER sounds @bell','[',
    ' |then (damage every #creature by 2',
    ' |then (cause @goblin attacks PLAYER','].',
    'WHEN @goblin attacks PLAYER','[',' |then (damage PLAYER','].'
  ].join('\n');
  const out=await encodeProfile1(compile(source));
  const code=out.sections.find(s=>s.id==='CODE');
  const start=code.offset+u32(out.bytes,code.offset+8);
  assert.equal(out.bytes[start],0x20);
  assert.equal(u32(out.bytes,start+4),4);
  const cause=start+16;
  assert.equal(out.bytes[cause],0x25);
});
test('higher Profiles fail closed and never emit a mislabeled Profile 1 binary',async()=>{
  const profile5= [
    'DEFINE','[',' @coin is a #thing','].',
    'START','[',' PLAYER has 0 score','].',
    'WHEN PLAYER takes @coin','[',' |then (increase score of PLAYER by 1','].'
  ].join('\n');
  await assert.rejects(encodeProfile1(compile(profile5)),BSBCEncodeError);
});
test('hex inspector remains limited and does not alter binary bytes',async()=>{
  const output=await encodeProfile1(compile(simple));
  const original=output.bytes.slice();
  const preview=hexView(output.bytes,32);
  assert.match(preview,/00000000\s+42 53 42 43/);
  assert.deepEqual(output.bytes,original);
});
