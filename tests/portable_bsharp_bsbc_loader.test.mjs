// Unexecuted regression definitions for the portable BSBC Profile 1 loader.
// Execution deferred until the owner explicitly resumes testing.
import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto} from 'node:crypto';
import {compile} from '../compiler/portable/bsharp_compiler.mjs';
import {encodeProfile1} from '../compiler/portable/bsharp_bsbc_encoder.mjs';
import {loadProfile1,BSBCLoadError} from '../compiler/portable/bsharp_bsbc_loader.mjs';

if(!globalThis.crypto?.subtle)globalThis.crypto=webcrypto;
const source=[
  'DEFINE','[',' @lamp is a #device',' @switch is a #device','].',
  'START','[',' @lamp is off',' PLAYER has 2 health','].',
  'WHEN PLAYER attacks @switch','[',' |then (change @lamp to on','].',
  'IF @lamp is on','[',' |then (damage PLAYER','].'
].join('\n');
const u32=(b,offset)=>new DataView(b.buffer,b.byteOffset,b.byteLength).getUint32(offset,true);
const set32=(b,offset,n)=>new DataView(b.buffer,b.byteOffset,b.byteLength).setUint32(offset,n,true);
const section=(b,name)=>{
  for(let i=0;i<8;i++){
    const off=32+i*16;
    if(String.fromCharCode(...b.slice(off,off+4))===name) return {
      directoryAt:off,offset:u32(b,off+4),length:u32(b,off+8),count:u32(b,off+12)
    };
  }
  throw Error('Fixture missing section '+name);
};
async function fixture(){return (await encodeProfile1(compile(source))).bytes;}
async function bad(change){
  const bytes=await fixture();
  change(bytes);
  assert.throws(()=>loadProfile1(bytes),BSBCLoadError);
}
test('loads complete valid Profile 1 binary and compares its program fingerprint',async()=>{
  const artifact=await encodeProfile1(compile(source));
  const model=loadProfile1(artifact.bytes,{expectedFingerprint:artifact.fingerprint});
  assert.equal(model.format,'bsharp.bytecode.bin');
  assert.equal(model.profile,'bsharp.bytecode.v1');
  assert.equal(model.fingerprint,artifact.fingerprint);
  assert.equal(model.events.length,1);
  assert.equal(model.ifRules.length,1);
  assert.equal(model.blocks.length,2);
  assert.equal(model.startRecords.length,2);
  assert(model.instructionCount>0);
});
test('loader does not modify input bytes',async()=>{
  const bytes=await fixture(),copy=bytes.slice();
  loadProfile1(bytes);
  assert.deepEqual(bytes,copy);
});
test('rejects forged fingerprint when the expected program fingerprint is supplied',async()=>{
  const output=await encodeProfile1(compile(source)),bytes=output.bytes.slice();
  assert.throws(()=>loadProfile1(bytes,{expectedFingerprint:'0'.repeat(64)}),BSBCLoadError);
  bytes[section(bytes,'META').offset+12]^=1;
  assert.throws(()=>loadProfile1(bytes,{expectedFingerprint:output.fingerprint}),BSBCLoadError);
  // Without trusted program meaning, the META fingerprint is only a declaration.
  // A structural parser cannot authenticate arbitrary bytes on its own.
});
test('rejects wrong magic and reserved fields',async()=>{
  await bad(b=>b[0]=0);
  await bad(b=>b[6]=2);
  await bad(b=>set32(b,28,1));
  await bad(b=>set32(b,24,b.length+4));
});
test('rejects malformed section identities, overlap, alignment, gaps and trailing bytes',async()=>{
  await bad(b=>b[32]='X'.charCodeAt(0));
  await bad(b=>set32(b,section(b,'THNG').directoryAt+4,section(b,'KIND').offset));
  await bad(b=>set32(b,section(b,'EVNT').directoryAt+4,section(b,'EVNT').offset+1));
  await bad(b=>set32(b,section(b,'META').directoryAt+8,0xffffffff));
  const extended=await fixture();
  const more=new Uint8Array(extended.length+4);more.set(extended);
  assert.throws(()=>loadProfile1(more),BSBCLoadError);
});
test('rejects malformed STRS lengths and invalid UTF-8',async()=>{
  await bad(b=>set32(b,section(b,'STRS').offset,0xffffffff));
  await bad(b=>{
    const str=section(b,'STRS').offset;
    b[str+4]=0xff;
  });
});
test('rejects forged META counts and Kind/Thing references',async()=>{
  await bad(b=>set32(b,section(b,'META').offset+44,999));
  await bad(b=>set32(b,section(b,'THNG').offset+4,0xffffffff));
  await bad(b=>set32(b,section(b,'KIND').offset+4,0));
});
test('rejects malformed START instruction opcode, record count and operands',async()=>{
  await bad(b=>b[section(b,'STRT').offset]=0xff);
  await bad(b=>b[section(b,'STRT').offset+1]=99);
  await bad(b=>set32(b,section(b,'STRT').offset+4,999));
  await bad(b=>b[section(b,'STRT').offset+2]=1);
});
test('rejects malformed WHEN selector, IF condition and CODE block boundaries',async()=>{
  await bad(b=>set32(b,section(b,'EVNT').offset,4));
  await bad(b=>b[section(b,'IFRL').offset]=0xff);
  await bad(b=>{
    const code=section(b,'CODE').offset;
    set32(b,code+8,0xffffffff);
  });
  await bad(b=>{
    const code=section(b,'CODE').offset;
    set32(b,code+4,9);
  });
  await bad(b=>{
    const code=section(b,'CODE').offset;
    const firstInstruction=code+u32(b,code+8);
    b[firstInstruction]=0xff;
  });
});
test('rejects higher bytecode profiles instead of partially interpreting them',async()=>{
  await bad(b=>b[6]=7);
});
