// Unexecuted regression definitions for BASIC# independent BSBC Profile 3.
// Do not execute until owner explicitly authorizes test runs.
import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto} from 'node:crypto';
import {compile,BSharpError} from '../compiler/portable/bsharp_compiler.mjs';
import {encodeBSBC,encodeProfile1,encodeProfile2,encodeProfile3,BSBCEncodeError} from '../compiler/portable/bsharp_bsbc_encoder.mjs';
import {loadBSBC,loadProfile2,loadProfile3,BSBCLoadError} from '../compiler/portable/bsharp_bsbc_loader.mjs';
import {BSharpBytecodeVM,BSBCVMError} from '../compiler/portable/bsharp_bsbc_vm.mjs';
if(!globalThis.crypto?.subtle)globalThis.crypto=webcrypto;

const input=lines=>lines.join('\n');
const demo=input([
 'KINDS','[',' #gate is a #door','].',
 'DEFINE','[',' @north gate is a #gate','].',
 'START','[',' @north gate is closed',' @north gate has "Heavy oak gate." description','].',
 'CONTROLS for PLAYER','[',' W moves PLAYER north',' S moves PLAYER south',
 ' A moves PLAYER west',' D moves PLAYER east',' PLAYER faces mouse pointer','].',
 'HOVER for #door','[',' name',' kind',' state',' description','].',
 'CONTEXT for #door','[',
 ' "Open" when it is closed (change it to open',
 ' "Close" when it is open (change it to closed',
 ' "Examine" (cause PLAYER examines it','].',
 'WHEN PLAYER examines @north gate','[',' |then (change @north gate to open','].'
]);
const worldThing=(vm,name)=>vm.snapshot().find(t=>t.name===name);
const u32=(bytes,at)=>new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength).getUint32(at,true);
const set32=(bytes,at,v)=>new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength).setUint32(at,v,true);
const section=(bytes,name)=>{
 for(let i=0;i<11;i++){
  const at=32+16*i;
  if(String.fromCharCode(...bytes.subarray(at,at+4))===name)
    return {directoryAt:at,offset:u32(bytes,at+4),length:u32(bytes,at+8),count:u32(bytes,at+12)};
 }
 throw Error('No '+name+' section');
};
const get=async()=>encodeBSBC(compile(demo));
test('CONTROLS, HOVER, CONTEXT retain exact established Profile 3 grammar and IR shapes',()=>{
 const ir=compile(demo);
 assert.equal(ir.meaning_profile,'bsharp.meaning.v3');
 assert.equal(ir.controls.length,1);
 assert.deepEqual(ir.controls[0].instructions.map(x=>x.type),
  ['key_move','key_move','key_move','key_move','face_pointer']);
 assert.equal(ir.hover_declarations[0].subject.kind_name,'door');
 assert.equal(ir.context_declarations[0].entries[0].action.target.type,'context_it');
 assert.equal(ir.context_declarations[0].entries[2].action.event.target.type,'context_it');
});
test('Profile 3 BSBC keeps official 11-section directory and identity strings',async()=>{
 const out=await get(),model=loadProfile3(out.bytes,{expectedFingerprint:out.fingerprint});
 assert.equal(out.profile,'bsharp.bytecode.v3');
 assert.equal(new DataView(out.bytes.buffer).getUint16(6,true),3);
 assert.equal(u32(out.bytes,12),11);
 assert.deepEqual(model.sections.map(row=>row.id),
  ['STRS','META','KIND','THNG','STRT','EVNT','IFRL','CTRL','HOVR','CTXT','CODE']);
 assert.deepEqual(model.strings.slice(0,3),
  ['bsharp.bytecode.v3','bsharp.meaning.v3','sha256-bsir-meaning-v3']);
 assert.equal(model.controls.length,1);
 assert.equal(model.hover_declarations.length,1);
 assert.equal(model.context_declarations.length,1);
});
test('Profile 3 binary roundtrip is deterministic without line-number dependencies',async()=>{
 const ir=compile(demo),updated=compile('\n\n'+demo);
 assert.deepEqual([...(await encodeBSBC(ir)).bytes],[...(await encodeBSBC(updated)).bytes]);
});
test('Profile 3 VM returns inherited hover information from validated binary',async()=>{
 const out=await get(),vm=new BSharpBytecodeVM(out.bytes,{expectedFingerprint:out.fingerprint});
 assert.deepEqual(vm.hoverFor('north gate'),[
  {field:'name',value:'north gate'},{field:'kind',value:'gate'},
  {field:'state',value:'closed'},{field:'description',value:'Heavy oak gate.'}
 ]);
});
test('Profile 3 context actions change state and re-evaluate visible menu',async()=>{
 const out=await get(),vm=new BSharpBytecodeVM(out.bytes,{expectedFingerprint:out.fingerprint});
 assert(vm.contextFor('north gate').some(x=>x.label==='Open'));
 assert(!vm.contextFor('north gate').some(x=>x.label==='Close'));
 vm.executeContext('north gate','Open');
 assert.deepEqual(worldThing(vm,'north gate').states,['open']);
 assert(!vm.contextFor('north gate').some(x=>x.label==='Open'));
 assert(vm.contextFor('north gate').some(x=>x.label==='Close'));
 vm.executeContext('north gate','Close');
 assert.deepEqual(worldThing(vm,'north gate').states,['closed']);
});
test('Profile 3 context cause may trigger a concrete WHEN rule and settle',async()=>{
 const out=await get(),vm=new BSharpBytecodeVM(out.bytes,{expectedFingerprint:out.fingerprint});
 vm.executeContext('north gate','Examine');
 assert.deepEqual(worldThing(vm,'north gate').states,['open']);
 assert(vm.trace.some(x=>x.startsWith('EVENT (BSBC): player examine north gate')));
});
test('Profile 3 context inheritance favors a more specific declaration',async()=>{
 const program=input([
  'KINDS','[',' #gate is a #door','].',
  'DEFINE','[',' @north gate is a #gate','].',
  'HOVER for #door','[',' name',' kind','].',
  'HOVER for #gate','[',' state','].',
  'CONTEXT for #door','[',' "Open" (change it to open','].',
  'CONTEXT for @north gate','[',' "Open" (change it to closed','].'
 ]);
 const out=await encodeBSBC(compile(program)),vm=new BSharpBytecodeVM(out.bytes);
 assert.deepEqual(vm.hoverFor('north gate').map(x=>x.field),['name','kind','state']);
 vm.executeContext('north gate','Open');
 assert.deepEqual(worldThing(vm,'north gate').states,['closed']);
});
test('control keys yield host-neutral intent and never mutate world state',async()=>{
 const out=await get(),vm=new BSharpBytecodeVM(out.bytes);
 const before=vm.snapshot();
 assert.deepEqual(vm.keyCommand('W'),{type:'move_intent',actor:'player',direction:'north',key:'W'});
 assert.deepEqual(vm.snapshot(),before);
 assert.throws(()=>vm.keyCommand('Z'),BSBCVMError);
});
test('context menu refuses unavailable actions',async()=>{
 const out=await get(),vm=new BSharpBytecodeVM(out.bytes);
 assert.throws(()=>vm.executeContext('north gate','Close'),BSBCVMError);
 assert.throws(()=>vm.executeContext('missing','Open'),BSBCVMError);
});
test('Profile 2 and Profile 1 strict APIs reject Profile 3 rather than reinterpret it',async()=>{
 const ir=compile(demo);
 await assert.rejects(encodeProfile1(ir),BSBCEncodeError);
 await assert.rejects(encodeProfile2(ir),BSBCEncodeError);
 const out=await encodeProfile3(ir);
 assert.throws(()=>loadProfile2(out.bytes),BSBCLoadError);
});
test('Profile 3 declares no platform movement support and fails unsupported controls',()=>{
 const src=input(['CONTROLS for PLAYER','[',' Q makes PLAYER fly','].']);
 assert.throws(()=>compile(src),BSharpError);
});
test('malformed Profile 3 section count is rejected',async()=>{
 const out=await get(),bytes=out.bytes.slice();
 set32(bytes,section(bytes,'CTXT').directoryAt+12,999);
 assert.throws(()=>loadBSBC(bytes),BSBCLoadError);
});
test('noncanonical Profile 3 game JSON cannot pass the strict loader',async()=>{
 const out=await get(),bytes=out.bytes.slice();
 const area=section(bytes,'HOVR');
 bytes[area.offset]=0x20;
 assert.throws(()=>loadBSBC(bytes),BSBCLoadError);
});
test('Profile 3 errors on missing context subjects and unknown HOVER fields',()=>{
 assert.throws(()=>compile(input([
  'HOVER for @missing','[',' name','].'
 ])),BSharpError);
 assert.throws(()=>compile(input([
  'DEFINE','[',' @gate is a #door','].',
  'HOVER for #door','[',' mystery','].'
 ])),BSharpError);
});
test('Profile 4 remains a strict unsupported boundary',async()=>{
 const ir=compile(demo);ir.meaning_profile='bsharp.meaning.v4';
 await assert.rejects(encodeBSBC(ir),BSBCEncodeError);
});
