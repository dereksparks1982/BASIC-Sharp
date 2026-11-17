// BASIC# Ruby-independent BSBC Profiles 1 and 2 structural loader.
// Source-only v0.0.85 candidate. Parses and validates but NEVER executes code.
// Profiles 3-7 fail closed until their distinct contracts are implemented.
export class BSBCLoadError extends Error {
  constructor(message) { super('BSBC rejected: '+message);this.name='BSBCLoadError'; }
}
const reject=message=>{throw new BSBCLoadError(message);};
const ORDER=['STRS','META','KIND','THNG','STRT','EVNT','IFRL','CODE'];
const NONE=0xffffffff,MAX=2147483647,MAX_BYTES=64*1024*1024;
const IDENTITIES={1:['bsharp.bytecode.v1','bsharp.meaning.v1','sha256-bsir-meaning-v1'],
  2:['bsharp.bytecode.v2','bsharp.meaning.v2','sha256-bsir-meaning-v2']};
const CODE={
  0x10:['START_STATE',3,'start'],
  0x11:['START_RELATION',3,'start'],
  0x12:['START_VALUE',3,'start'],
  0x13:['START_TEXT_VALUE',3,'start'],
  0x20:['DAMAGE',3,'action'],
  0x21:['CHANGE_STATE',4,'action'],
  0x22:['CHANGE_VALUE',4,'action'],
  0x23:['CARRY',2,'action'],
  0x24:['UNLOCK',2,'action'],
  0x25:['CAUSE_EVENT',5,'action'],
  0x26:['CHANGE_TEXT_VALUE',4,'action']
};
const CONDITION={
  0x30:['STATE_IS',2],
  0x31:['STATE_ISNT',2],
  0x32:['RELATION_EXISTS',3],
  0x33:['VALUE_EQUALS',3],
  0x34:['TEXT_VALUE_EQUALS',3]
};
const SELECTOR={
  1:'EXACT_THING',2:'ONE_KIND',3:'BOUND_THAT_KIND',4:'EVERY_KIND',255:'NO_REFERENCE'
};
const REFERENCE_CONTEXT={
  eventActor:new Set([1,2]),
  eventTarget:new Set([1,2,255]),
  action:new Set([1,3,4]),
  causeActor:new Set([1,2,3]),
  causeTarget:new Set([1,2,3,255])
};
const normalized=s=>s.trim().toLowerCase().replace(/\s+/gu,' ');
const printable=bytes=>Array.from(bytes,b=>b.toString(16).padStart(2,'0')).join('');
const align=x=>x+(4-x%4)%4;
const utf8=new TextDecoder('utf-8',{fatal:true,ignoreBOM:true});
const ascii=(bytes,offset,size)=>String.fromCharCode(...bytes.subarray(offset,offset+size));
function asUint8Array(value) {
  if(!(value instanceof Uint8Array))reject('input must be binary Uint8Array bytes.');
  if(value.byteLength>MAX_BYTES)reject('input is larger than the 64 MiB browser validation limit.');
  return new Uint8Array(value); // prevent caller-side mutation during parse
}
function ensure(bytes,offset,size,where,end=bytes.length) {
  if(!Number.isSafeInteger(offset)||!Number.isSafeInteger(size)||offset<0||size<0||
     end>bytes.length||offset>end||size>end-offset)reject('truncated '+where+'.');
}
const whole=(v,label,min=0)=>{if(!Number.isInteger(v)||v<min||v>MAX)reject(label+' exceeds permitted whole-number range.');};
function loadWithProfile(input,{expectedFingerprint=null,requiredProfile=null}={}) {
  const bytes=asUint8Array(input),dv=new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength);
  const u32=(offset)=>{ensure(bytes,offset,4,'u32');return dv.getUint32(offset,true);};
  const u16=(offset)=>{ensure(bytes,offset,2,'u16');return dv.getUint16(offset,true);};
  const checked=(offset,length,where,end=bytes.length)=>ensure(bytes,offset,length,where,end);
  if(bytes.length<160)reject('header or section directory is truncated.');
  if(ascii(bytes,0,4)!=='BSBC')reject('wrong four-byte BSBC magic.');
  if(u16(4)!==1)reject('unsupported binary format version.');
  const version=u16(6);
  if(!IDENTITIES[version])reject('only BSBC Profiles 1 and 2 are currently supported.');
  if(requiredProfile!==null&&version!==requiredProfile)reject('expected BSBC Profile '+requiredProfile+', received '+version+'.');
  const ID=IDENTITIES[version];
  if(u32(8)!==32||u32(12)!==8||u32(16)!==32||u32(20)!==16)reject('invalid header or section directory layout.');
  if(u32(24)!==bytes.length)reject('declared file size disagrees with bytes.');
  if(u32(28)!==0)reject('nonzero reserved header field.');
  const directory=[],regions=new Map();
  let lastEnd=160;
  for(let i=0;i<ORDER.length;i++) {
    const at=32+i*16,id=ascii(bytes,at,4);
    if(id!==ORDER[i])reject('section order, identity or duplicate is invalid at #'+(i+1)+'.');
    const offset=u32(at+4),length=u32(at+8),count=u32(at+12);
    if(offset%4!==0)reject(id+' section must start at a four-byte boundary.');
    if(offset!==align(lastEnd))reject(id+' section has an overlap or unexplained gap.');
    checked(offset,length,id+' section');
    for(let p=lastEnd;p<offset;p++)if(bytes[p]!==0)reject(id+' section alignment padding is not zero.');
    lastEnd=offset+length;
    if(count>MAX_BYTES)reject(id+' record count is implausibly large.');
    const row={id,offset,length,count};directory.push(row);regions.set(id,row);
  }
  if(lastEnd!==bytes.length)reject('trailing unexplained data.');
  const region=id=>regions.get(id);
  function stringFrom(offset,length,label) {
    checked(offset,length,label);
    const sub=bytes.subarray(offset,offset+length);
    let value;
    try {value=utf8.decode(sub);} catch (_) {reject(label+' is invalid UTF-8.');}
    return value;
  }
  const strings=[],strRegion=region('STRS');
  let cursor=strRegion.offset;
  if(strRegion.count>Math.floor(strRegion.length/4))reject('STRS count exceeds section size.');
  for(let i=0;i<strRegion.count;i++) {
    checked(cursor,4,'STRS length',strRegion.offset+strRegion.length);
    const length=u32(cursor);cursor+=4;
    checked(cursor,length,'STRS string',strRegion.offset+strRegion.length);
    const item=stringFrom(cursor,length,'STRS string');cursor+=length;
    const aligned=align(cursor);
    checked(cursor,aligned-cursor,'STRS padding',strRegion.offset+strRegion.length);
    for(let p=cursor;p<aligned;p++)if(bytes[p]!==0)reject('STRS padding is not zero.');
    cursor=aligned;strings.push(item);
  }
  if(cursor!==strRegion.offset+strRegion.length)reject('STRS has trailing or incomplete records.');
  if(new Set(strings).size!==strings.length)reject('duplicate STRS entry.');
  if(strings.length<3||ID.some((x,i)=>strings[i]!==x))reject('wrong mandatory string identities.');
  const stringIndex=i=>{if(i>=strings.length)reject('out-of-range string index '+i+'.');return strings[i];};
  const optionalString=i=>{if(i!==NONE)stringIndex(i);};
  const meta=region('META');
  if(meta.count!==1||meta.length!==68)reject('META must contain exactly one 68-byte record.');
  const mo=meta.offset;
  if(u32(mo)!==0||u32(mo+4)!==1||u32(mo+8)!==2)reject('META identity indexes are not canonical.');
  const fingerprint=printable(bytes.subarray(mo+12,mo+44));
  if(expectedFingerprint!==null) {
    if(typeof expectedFingerprint!=='string'||!/^[0-9a-f]{64}$/iu.test(expectedFingerprint))reject('expected fingerprint must be 64 hexadecimal characters.');
    if(fingerprint!==expectedFingerprint.toLowerCase())reject('fingerprint disagrees with the supplied program meaning.');
  }
  const counts=['KIND','THNG','STRT','EVNT','IFRL','CODE'];
  for(let i=0;i<counts.length;i++) {
    if(u32(mo+44+4*i)!==region(counts[i]).count)reject('META count does not match '+counts[i]+'.');
  }
  const kinds=[],kindRegion=region('KIND');
  if(kindRegion.count*12!==kindRegion.length)reject('KIND record size/count mismatch.');
  const kindNames=new Set();
  for(let i=0;i<kindRegion.count;i++) {
    const at=kindRegion.offset+12*i,nameIndex=u32(at),parent=u32(at+4),order=u32(at+8),name=stringIndex(nameIndex);
    if(kindNames.has(name))reject('duplicate Kind '+name+'.');
    kindNames.add(name);
    if(order!==i)reject('Kind source order is not canonical.');
    if(parent!==NONE&&parent>=i)reject('Kind parent index must precede its descendant.');
    kinds.push({name,nameIndex,parent,sourceOrder:i});
  }
  const kindIndex=i=>{if(i>=kinds.length)reject('invalid Kind index '+i+'.');};
  const things=[],thingRegion=region('THNG');
  if(thingRegion.count*12!==thingRegion.length)reject('THNG record size/count mismatch.');
  const thingNames=new Set();
  for(let i=0;i<thingRegion.count;i++) {
    const at=thingRegion.offset+i*12,nameIndex=u32(at),kindIndexValue=u32(at+4),order=u32(at+8);
    const name=stringIndex(nameIndex);kindIndex(kindIndexValue);
    if(thingNames.has(name))reject('duplicate Thing '+name+'.');
    thingNames.add(name);
    if(order!==i)reject('Thing definition order is not canonical.');
    things.push({name,nameIndex,kindIndex:kindIndexValue,definitionOrder:i});
  }
  const thingIndex=i=>{if(i>=things.length)reject('invalid Thing index '+i+'.');};
  function selector(code,index,context) {
    const name=SELECTOR[code],allowed=REFERENCE_CONTEXT[context];
    if(!name||!allowed.has(code))reject('invalid '+context+' selector '+code+'.');
    if(code===255) {if(index!==NONE)reject('NO_REFERENCE must use 0xFFFFFFFF.');}
    else if(code===1) thingIndex(index);
    else kindIndex(index);
    return {name,code,index};
  }
  function record(offset,end,context) {
    checked(offset,4,context+' record header',end);
    const opcode=bytes[offset],count=bytes[offset+1],reserved=u16(offset+2);
    if(reserved!==0)reject('nonzero '+context+' reserved instruction field.');
    const table=context==='condition'?CONDITION:CODE,def=table[opcode];
    if(!def||def[1]!==count)reject('unknown '+context+' opcode or wrong operand count: '+opcode+'.');
    if(version===1 && ['START_TEXT_VALUE','CHANGE_TEXT_VALUE','TEXT_VALUE_EQUALS'].includes(def[0])) {
      reject('Profile 2 text instruction '+def[0]+' cannot occur in Profile 1 bytecode.');
    }
    if(context!=='condition' && def[2]!==context)reject('opcode '+def[0]+' is not allowed in '+context+'.');
    const finish=offset+4+count*4;
    checked(offset,4+count*4,context+' record',end);
    const operands=Array.from({length:count},(_,i)=>u32(offset+4+i*4));
    const decoded={name:def[0],opcode,operands};
    return {decoded,next:finish};
  }
  function validateStart(r) {
    const a=r.operands;
    thingIndex(a[0]);
    switch(r.name) {
      case 'START_STATE':stringIndex(a[1]);optionalString(a[2]);break;
      case 'START_RELATION':stringIndex(a[1]);thingIndex(a[2]);break;
      case 'START_VALUE':stringIndex(a[1]);whole(a[2],'START_VALUE');break;
      case 'START_TEXT_VALUE':
        stringIndex(a[1]);stringIndex(a[2]);
        if(strings[a[1]]==='damage')reject('damage cannot be a text value.');
        break;
      default:reject('invalid START opcode.');
    }
  }
  function validateCondition(r) {
    const a=r.operands;thingIndex(a[0]);stringIndex(a[1]);
    if(r.name==='RELATION_EXISTS')thingIndex(a[2]);
    if(r.name==='VALUE_EQUALS')whole(a[2],'VALUE_EQUALS');
    if(r.name==='TEXT_VALUE_EQUALS')stringIndex(a[2]);
  }
  function validateAction(r) {
    const a=r.operands;
    if(r.name==='CAUSE_EVENT') {
      selector(a[0],a[1],'causeActor');stringIndex(a[2]);selector(a[3],a[4],'causeTarget');return;
    }
    selector(a[0],a[1],'action');
    if(r.name==='DAMAGE')whole(a[2],'DAMAGE',1);
    if(r.name==='CHANGE_STATE'){stringIndex(a[2]);optionalString(a[3]);}
    if(r.name==='CHANGE_VALUE'){stringIndex(a[2]);whole(a[3],'CHANGE_VALUE');}
    if(r.name==='CHANGE_TEXT_VALUE'){
      stringIndex(a[2]);stringIndex(a[3]);
      if(strings[a[2]]==='damage')reject('damage cannot store text.');
    }
  }
  const starts=[],start=region('STRT');
  cursor=start.offset;
  if(start.count>Math.floor(start.length/4))reject('STRT count cannot fit in section.');
  for(let i=0;i<start.count;i++){
    const {decoded,next}=record(cursor,start.offset+start.length,'start');validateStart(decoded);starts.push(decoded);cursor=next;
  }
  if(cursor!==start.offset+start.length)reject('STRT has unexplained trailing bytes.');
  const events=[],ev=region('EVNT');
  if(ev.count*28!==ev.length)reject('EVNT record size/count mismatch.');
  const code=region('CODE');
  for(let i=0;i<ev.count;i++) {
    const at=ev.offset+i*28,aSel=u32(at),aRef=u32(at+4),actionIndex=u32(at+8),tSel=u32(at+12),
      tRef=u32(at+16),block=u32(at+20),order=u32(at+24);
    selector(aSel,aRef,'eventActor');selector(tSel,tRef,'eventTarget');stringIndex(actionIndex);
    if(block!==i||order!==i||block>=code.count)reject('WHEN block or source order is not canonical.');
    events.push({actorSelector:aSel,actorReference:aRef,actionStringIndex:actionIndex,
      targetSelector:tSel,targetReference:tRef,blockIndex:block,sourceOrder:order});
  }
  const ifRules=[],ifRegion=region('IFRL');cursor=ifRegion.offset;
  if(ifRegion.count>Math.floor(ifRegion.length/16))reject('IFRL count cannot fit in section.');
  for(let i=0;i<ifRegion.count;i++) {
    const parsed=record(cursor,ifRegion.offset+ifRegion.length,'condition');
    validateCondition(parsed.decoded);cursor=parsed.next;
    checked(cursor,8,'IFRL block fields',ifRegion.offset+ifRegion.length);
    const block=u32(cursor),order=u32(cursor+4);cursor+=8;
    if(block!==ev.count+i||order!==i||block>=code.count)reject('IF block or source order is not canonical.');
    ifRules.push({condition:parsed.decoded,blockIndex:block,sourceOrder:order});
  }
  if(cursor!==ifRegion.offset+ifRegion.length)reject('IFRL has unexplained trailing bytes.');
  if(code.count!==ev.count+ifRegion.count)reject('CODE count must equal WHEN + IF blocks.');
  const blocks=[];const codeStart=code.offset,codeEnd=code.offset+code.length;
  checked(codeStart,4,'CODE block count',codeEnd);
  if(u32(codeStart)!==code.count)reject('CODE embedded block count differs from directory.');
  const blockDirEnd=4+code.count*16;
  if(blockDirEnd>code.length)reject('CODE block directory is truncated.');
  let previous=blockDirEnd;
  for(let i=0;i<code.count;i++) {
    const at=codeStart+4+i*16,id=u32(at),offset=u32(at+4),length=u32(at+8),count=u32(at+12);
    if(id!==i)reject('CODE block ids must be zero-based and ordered.');
    if(offset%4!==0||offset!==previous)reject('CODE block offset, alignment or contiguous order is invalid.');
    if(offset>code.length||length>code.length-offset)reject('CODE block boundary exceeds section.');
    let pos=codeStart+offset;const end=pos+length;
    if(count>Math.floor(length/4))reject('CODE instruction count exceeds block size.');
    const instructions=[];
    for(let j=0;j<count;j++){
      const parsed=record(pos,end,'action');validateAction(parsed.decoded);
      instructions.push(parsed.decoded);pos=parsed.next;
    }
    if(pos!==end)reject('CODE block contains incomplete instruction or unexplained bytes.');
    previous=offset+length;
    blocks.push({id,offset,length,instructions});
  }
  if(previous!==code.length)reject('CODE has trailing unexplained data.');
  const used=[],roles=Array.from({length:strings.length},()=>new Set());
  function mark(i,role='identifier') {
    stringIndex(i);roles[i].add(role);
    if(!used.includes(i))used.push(i);
  }
  function optionalMark(i) {if(i!==NONE)mark(i);}
  [0,1,2].forEach(i=>mark(i));
  for(const k of kinds)mark(k.nameIndex);
  for(const t of things)mark(t.nameIndex);
  function markInstruction(r) {
    const a=r.operands;
    switch(r.name) {
      case 'START_STATE':mark(a[1]);optionalMark(a[2]);break;
      case 'START_RELATION':case 'START_VALUE':mark(a[1]);break;
      case 'START_TEXT_VALUE':mark(a[1]);mark(a[2],'literal');break;
      case 'CHANGE_STATE':mark(a[2]);optionalMark(a[3]);break;
      case 'CHANGE_VALUE':mark(a[2]);break;
      case 'CHANGE_TEXT_VALUE':mark(a[2]);mark(a[3],'literal');break;
      case 'CAUSE_EVENT':mark(a[2]);break;
    }
  }
  for(const r of starts)markInstruction(r);
  for(const e of events)mark(e.actionStringIndex);
  for(const r of ifRules) {
    mark(r.condition.operands[1]);
    if(r.condition.name==='TEXT_VALUE_EQUALS')mark(r.condition.operands[2],'literal');
  }
  for(const b of blocks)for(const r of b.instructions)markInstruction(r);
  if(used.length!==strings.length||used.some((i,n)=>i!==n))reject('STRS contains unused entries or noncanonical first-use order.');
  for(let i=0;i<strings.length;i++){
    if(roles[i].has('identifier')&&strings[i]!==normalized(strings[i]))reject('noncanonical identifier string at STRS #'+i+'.');
  }
  // Exact creator text remains case-sensitive; do not normalize literal roles.
  for(let i=0;i<strings.length;i++) {
    const literal=roles[i].has('literal');
    if(literal && (strings[i].includes('\n')||strings[i].includes('\r')||
       strings[i].includes('\\')||strings[i].includes('#{')||strings[i].includes('"'))) {
      reject('invalid Profile 2 creator text literal at STRS #'+i+'.');
    }
  }
  // Match the Ruby loader's global value-name type contract, not merely
  // the individual Thing's value. One name cannot be text and a number.
  const schemas=new Map([['damage','number']]),assigned=new Set();
  function rememberType(valueIndex,type,where) {
    const name=strings[valueIndex];
    if(!/^[a-z][a-z0-9]*$/u.test(name))reject('invalid value name at '+where+'.');
    if(schemas.has(name)&&schemas.get(name)!==type) {
      reject(where+' uses '+name+' as '+type+' but the established type is '+schemas.get(name)+'.');
    }
    schemas.set(name,type);
  }
  for(const r of starts)if(r.name==='START_VALUE'||r.name==='START_TEXT_VALUE') {
    const a=r.operands,key=a[0]+':'+a[1];
    if(assigned.has(key))reject('duplicate starting value assignment.');
    assigned.add(key);
    rememberType(a[1],r.name==='START_TEXT_VALUE'?'text':'number',r.name);
  }
  for(const rule of ifRules) {
    const r=rule.condition;
    if(r.name==='VALUE_EQUALS'||r.name==='TEXT_VALUE_EQUALS') {
      rememberType(r.operands[1],r.name==='TEXT_VALUE_EQUALS'?'text':'number',r.name);
    }
  }
  for(const block of blocks)for(const r of block.instructions) {
    if(r.name==='CHANGE_VALUE'||r.name==='CHANGE_TEXT_VALUE') {
      rememberType(r.operands[2],r.name==='CHANGE_TEXT_VALUE'?'text':'number',r.name);
    }
  }
  const usesText=starts.some(r=>r.name==='START_TEXT_VALUE')||
    ifRules.some(r=>r.condition.name==='TEXT_VALUE_EQUALS')||
    blocks.some(block=>block.instructions.some(r=>r.name==='CHANGE_TEXT_VALUE'));
  if(version===2&&!usesText)reject('BSBC Profile 2 requires at least one creator-facing text value.');
  const result={
    format:'bsharp.bytecode.bin',
    profile:ID[0],meaningProfile:ID[1],fingerprintAlgorithm:ID[2],fingerprint,
    byteLength:bytes.length,sections:directory,strings,kinds,things,
    startRecords:starts,events,ifRules,blocks,
    instructionCount:blocks.reduce((sum,b)=>sum+b.instructions.length,0),
    validation:'Profile '+version+' structural parse complete; binary not executed'
  };
  return result;
}

// The named Profile APIs are strict and never accept a different header version.
export function loadProfile1(bytes, options={}) {return loadWithProfile(bytes,{...options,requiredProfile:1});}
export function loadProfile2(bytes, options={}) {return loadWithProfile(bytes,{...options,requiredProfile:2});}
export function loadBSBC(bytes, options={}) {return loadWithProfile(bytes,options);}
