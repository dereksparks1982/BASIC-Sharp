// BASIC# portable BSBC Profile 1 binary emitter (development candidate).
// Produces the established BSBC container, not an alternative JSON format.
// Independent of Ruby. No code is executed: this module only serializes resolved IR.
// Profiles 2-7 MUST be rejected until their full contracts are implemented.
const ORDER = ['STRS','META','KIND','THNG','STRT','EVNT','IFRL','CODE'];
const NONE = 0xffffffff, MAX = 2147483647;
const PROFILE = 'bsharp.bytecode.v1';
const MEANING = 'bsharp.meaning.v1';
const FINGERPRINT = 'sha256-bsir-meaning-v1';
const MAGIC = [66,83,66,67];
const SELECTOR = Object.freeze({object:1,kind_one:2,kind:2,previous:3,kind_set:4});
const OPPOSITE = Object.freeze({
  open:'closed',closed:'open',locked:'unlocked',unlocked:'locked',
  alive:'dead',dead:'alive',calm:'angry',angry:'calm',
  friendly:'hostile',hostile:'friendly',visible:'hidden',hidden:'visible',
  carried:'dropped',dropped:'carried',broken:'whole',whole:'broken',on:'off',off:'on'
});
const OP = Object.freeze({
  START_STATE:0x10,START_RELATION:0x11,START_VALUE:0x12,
  DAMAGE:0x20,CHANGE_STATE:0x21,CHANGE_VALUE:0x22,CARRY:0x23,
  UNLOCK:0x24,CAUSE_EVENT:0x25,STATE_IS:0x30,STATE_ISNT:0x31,
  RELATION_EXISTS:0x32,VALUE_EQUALS:0x33
});
const textEncoder = new TextEncoder();
const norm = value => String(value ?? '').trim().toLowerCase().replace(/\s+/gu,' ');
const records = value => Array.isArray(value) ? value : [];
const has = (value,key) => Object.prototype.hasOwnProperty.call(value,key);
const no = message => { throw new BSBCEncodeError(message); };

export class BSBCEncodeError extends Error {
  constructor(message) { super(message); this.name='BSBCEncodeError'; }
}
function u32(value,where) {
  if (!Number.isInteger(value) || value<0 || value>NONE) no(where+' is not a valid unsigned 32-bit number.');
  return value;
}
function whole(value,where,minimum=0) {
  if (!Number.isInteger(value) || value<minimum || value>MAX) no(where+' must be between '+minimum+' and '+MAX+'.');
  return value;
}
function pack32(...numbers) {
  const buffer = new Uint8Array(4*numbers.length);
  const view = new DataView(buffer.buffer);
  for(let i=0;i<numbers.length;i++)view.setUint32(i*4,u32(numbers[i],'BSBC field'),true);
  return buffer;
}
function pack16(value) {
  const bytes=new Uint8Array(2);new DataView(bytes.buffer).setUint16(0,value,true);return bytes;
}
function join(...parts) {
  const size=parts.reduce((n,bytes)=>n+bytes.length,0);
  if(size>NONE)no('BSBC file exceeds the supported size.');
  const output=new Uint8Array(size);let at=0;
  for(const bytes of parts){output.set(bytes,at);at+=bytes.length;}
  return output;
}
function pad(length) {return new Uint8Array((4-length%4)%4);}
function bytesForText(value) {return textEncoder.encode(value);}
function rec(opcode, operands) {
  if (!Number.isInteger(opcode)||opcode<0||opcode>255||operands.length>255) no('Unsupported BSBC record opcode or operand count.');
  return join(Uint8Array.of(opcode,operands.length,0,0),pack32(...operands));
}
function meaningCanonical(value) {
  if(Array.isArray(value))return value.map(meaningCanonical);
  if(value && typeof value==='object') {
    const object={};
    for(const key of Object.keys(value).filter(key=>key!=='line_number').sort())object[key]=meaningCanonical(value[key]);
    return object;
  }
  return value;
}
export async function meaningFingerprint(ir) {
  // Matches WorldSave.program_fingerprint: SHA-256 of canonical sorted,
  // line-number-free JSON for kinds, objects, facts, events, if_rules.
  if(!globalThis.crypto?.subtle?.digest)no('BSharp fingerprint requires a secure browser with Web Crypto SHA-256.');
  const source={};
  for(const key of ['kinds','objects','facts','events','if_rules'])source[key]=records(ir[key]);
  const digest=await globalThis.crypto.subtle.digest('SHA-256',bytesForText(JSON.stringify(meaningCanonical(source))));
  return new Uint8Array(digest);
}
function assertProfile1(ir) {
  if(!ir||ir.format!=='bsir.debug.json')no('BSBC expects resolved BSharp IR.');
  if(ir.meaning_profile && ir.meaning_profile!==MEANING) {
    no('This first portable BSBC emitter supports Profile 1 only. '+ir.meaning_profile+' requires a later encoder.');
  }
  if(records(ir.diagnostics).some(x=>x.severity==='error'||x.severity==='warning'))no('BSBC will not encode IR containing errors or warnings.');
  for(const name of ['controls','hover_declarations','context_declarations']) {
    if(records(ir[name]).length)no(name+' needs a higher bytecode profile.');
  }
  for(const fact of records(ir.facts))if(has(fact,'text_value'))no('Text values require BSBC Profile 2.');
  for(const rule of records(ir.if_rules)) {
    if(has(rule,'otherwise'))no('OTHERWISE requires BSBC Profile 7.');
    if(rule.if?.connector)no('Compound IF requires BSBC Profile 6.');
    if(has(rule.if||{},'text_value'))no('Text IF requires BSBC Profile 2.');
    if(rule.if?.comparison && rule.if.comparison!=='equals')no('Threshold IF requires BSBC Profile 5.');
  }
  for(const action of [...records(ir.events).flatMap(x=>records(x.then)),
    ...records(ir.if_rules).flatMap(x=>records(x.then))]) {
    if(['increase','decrease'].includes(action.action))no('Numeric changes require BSBC Profile 5.');
    if(has(action,'to_text'))no('Text changes require BSBC Profile 2.');
  }
}
// Builds all binary sections with the same semantic traversal and first-use
// string interning rules as SmallCompilerSubsetBSBCEncoder (Ruby referee).
export async function encodeProfile1(ir) {
  assertProfile1(ir);
  const fingerprint=await meaningFingerprint(ir);
  if(fingerprint.length!==32)no('BSBC fingerprint must be exactly 32 bytes.');
  const strings=[],indexes=new Map();
  function intern(value) {
    if(typeof value!=='string')no('BSBC string must be UTF-8 text.');
    const current=indexes.get(value);
    if(current!==undefined)return current;
    const index=strings.length;strings.push(value);indexes.set(value,index);return index;
  }
  for(const str of [PROFILE,MEANING,FINGERPRINT])intern(str);
  const irKinds=records(ir.kinds),irObjects=records(ir.objects),irEvents=records(ir.events),irIfs=records(ir.if_rules);
  const customParents=new Map(irKinds.map(x=>[norm(x.name),norm(x.parent)]));
  const allKinds=[],kindIds=new Map();
  function addKind(raw, visiting=new Set()) {
    const name=norm(raw);
    if(!name||kindIds.has(name))return;
    if(visiting.has(name))no('BSBC Kind ancestry circle at #'+name);
    visiting.add(name);
    const parent=customParents.get(name);
    if(parent)addKind(parent,visiting);
    visiting.delete(name);
    kindIds.set(name,allKinds.length);allKinds.push(name);
  }
  function includeRef(ref) {
    if(!ref)return;
    const name=norm(ref.kind_name||ref.object_kind);
    if(name)addKind(name);
  }
  function includeAction(action) {
    includeRef(action.target);
    if(action.event){includeRef(action.event.actor);includeRef(action.event.target);}
  }
  for(const kind of irKinds){addKind(kind.parent);addKind(kind.name);}
  for(const obj of irObjects)addKind(obj.kind);
  for(const event of irEvents) {
    includeRef(event.when?.actor);includeRef(event.when?.target);
    for(const action of records(event.then))includeAction(action);
  }
  for(const rule of irIfs)for(const action of records(rule.then))includeAction(action);
  const kindRows=allKinds.map((name,index)=>{
    const parent=customParents.get(name);
    return [intern(name),parent?requireIndex(kindIds,parent,'parent Kind'):NONE,index];
  });
  const thingIds=new Map(),thingRows=irObjects.map((obj,index)=>{
    const name=norm(obj.name);
    if(!name||thingIds.has(name))no('Duplicate or unnamed Thing '+name);
    thingIds.set(name,index);
    return [intern(name),requireIndex(kindIds,norm(obj.kind),'Thing Kind'),index];
  });
  function thing(ref) {
    if(!ref||ref.type!=='object')no('START/IF requires one resolved named Thing.');
    return requireIndex(thingIds,norm(ref.name||ref.text),'Thing');
  }
  function selector(ref,context,optional=false) {
    if(ref==null) {
      if(optional)return [255,NONE];
      no(context+' requires a reference.');
    }
    const value=SELECTOR[ref.type];
    if(value===undefined)no(context+' has an unsupported reference '+ref.type);
    const allowed=context==='event' ? [1,2] : context==='action' ? [1,3,4] : [1,2,3];
    if(!allowed.includes(value))no('Selector '+ref.type+' is not valid for '+context);
    return [value,value===1?thing(ref):requireIndex(kindIds,norm(ref.kind_name||ref.object_kind),'Kind selector')];
  }
  function stateName(value,where) {
    if(!value || value.kind!=='state'||!value.name)no(where+' needs a known state.');
    return norm(value.name);
  }
  const starts=records(ir.facts).map(fact=>{
    const owner=thing(fact.subject);
    switch(fact.relation) {
      case 'is': {
        const value=stateName(fact.value,'START');
        return rec(OP.START_STATE,[owner,intern(value),OPPOSITE[value]?intern(OPPOSITE[value]):NONE]);
      }
      case 'has':
        if(has(fact,'text_value'))no('Text values require Profile 2.');
        return rec(OP.START_VALUE,[owner,intern(norm(fact.value_name)),whole(fact.amount,'START value')]);
      default:
        if(!fact.target)no('Relation START requires a resolved target.');
        return rec(OP.START_RELATION,[owner,intern(norm(fact.relation)),thing(fact.target)]);
    }
  });
  const events=irEvents.map((event,index)=>{
    const [aSel,aRef]=selector(event.when?.actor,'event');
    const [tSel,tRef]=selector(event.when?.target,'event',true);
    const action=intern(norm(event.when?.action));
    return [aSel,aRef,action,tSel,tRef,index,index];
  });
  function condition(condition) {
    if(!condition||typeof condition!=='object')no('IF needs a resolved condition.');
    if(condition.connector)no('Compound IF requires Profile 6.');
    const owner=thing(condition.subject);
    if(condition.relation==='is'||condition.relation==='isnt') {
      return rec(condition.relation==='is'?OP.STATE_IS:OP.STATE_ISNT,
        [owner,intern(stateName(condition.value,'IF'))]);
    }
    if(condition.relation==='has') {
      if(has(condition,'text_value'))no('Text IF requires Profile 2.');
      if(condition.comparison && condition.comparison!=='equals')no('Threshold IF requires Profile 5.');
      return rec(OP.VALUE_EQUALS,[owner,intern(norm(condition.value_name)),whole(condition.amount,'IF value')]);
    }
    if(!condition.target)no('Relation IF must name a Thing.');
    return rec(OP.RELATION_EXISTS,[owner,intern(norm(condition.relation)),thing(condition.target)]);
  }
  const ifRows=irIfs.map((rule,index)=>join(condition(rule.if),pack32(irEvents.length+index,index)));
  function actionRecord(action) {
    const verb=norm(action.action);
    if(verb==='cause') {
      const caused=action.event;
      if(!caused)no('(cause requires an event.');
      const [aSel,aRef]=selector(caused.actor,'caused');
      const [tSel,tRef]=selector(caused.target,'caused',true);
      return rec(OP.CAUSE_EVENT,[aSel,aRef,intern(norm(caused.action)),tSel,tRef]);
    }
    const [sel,ref]=selector(action.target,'action');
    switch(verb) {
      case 'damage':return rec(OP.DAMAGE,[sel,ref,whole(action.amount ?? 1,'Damage',1)]);
      case 'change': {
        if(action.value_name) {
          if(has(action,'to_text'))no('Text changes require Profile 2.');
          return rec(OP.CHANGE_VALUE,[sel,ref,intern(norm(action.value_name)),whole(action.to_amount,'Value assignment')]);
        }
        const value=stateName(action.to,'Change action');
        return rec(OP.CHANGE_STATE,[sel,ref,intern(value),OPPOSITE[value]?intern(OPPOSITE[value]):NONE]);
      }
      case 'carry':return rec(OP.CARRY,[sel,ref]);
      case 'unlock':return rec(OP.UNLOCK,[sel,ref]);
      default:no('BSBC Profile 1 cannot encode action '+verb);
    }
  }
  const blocks=[
    ...irEvents.map(e=>records(e.then).map(actionRecord)),
    ...irIfs.map(rule=>records(rule.then).map(actionRecord))
  ];
  const codeBodies=blocks.map(block=>join(...block));
  const codeHeader=pack32(blocks.length);
  let codeOffset=4+blocks.length*16;
  const codeEntries=codeBodies.map((bytes,id)=>{
    const row=pack32(id,codeOffset,bytes.length,blocks[id].length);
    codeOffset+=bytes.length;return row;
  });
  const code=join(codeHeader,...codeEntries,...codeBodies);
  const stringsSection=join(...strings.map(value=>{
    const bytes=bytesForText(value);
    return join(pack32(bytes.length),bytes,pad(4+bytes.length));
  }));
  const meta=join(pack32(0,1,2),fingerprint,pack32(allKinds.length,irObjects.length,starts.length,events.length,ifRows.length,blocks.length));
  const sections={
    STRS:stringsSection,META:meta,
    KIND:join(...kindRows.map(row=>pack32(...row))),
    THNG:join(...thingRows.map(row=>pack32(...row))),
    STRT:join(...starts),
    EVNT:join(...events.map(row=>pack32(...row))),
    IFRL:join(...ifRows),CODE:code
  };
  const counts={
    STRS:strings.length,META:1,KIND:allKinds.length,THNG:irObjects.length,
    STRT:starts.length,EVNT:events.length,IFRL:ifRows.length,CODE:blocks.length
  };
  let at=32+ORDER.length*16;
  const sectionDirectory=[],payload=[];
  for(const id of ORDER){
    const leading=pad(at);
    payload.push(leading);at+=leading.length;
    const data=sections[id];sectionDirectory.push({id,offset:at,length:data.length,count:counts[id]});
    payload.push(data);at+=data.length;
  }
  const directory=join(...sectionDirectory.map(row=>join(bytesForText(row.id),pack32(row.offset,row.length,row.count))));
  const header=join(Uint8Array.from(MAGIC),pack16(1),pack16(1),pack32(32,ORDER.length,32,16,at,0));
  const bytes=join(header,directory,...payload);
  if(header.length!==32||directory.length!==128||bytes.length!==at)no('BSBC header or section size mismatch.');
  return {bytes,profile:PROFILE,meaningProfile:MEANING,
    fingerprint:[...fingerprint].map(byte=>byte.toString(16).padStart(2,'0')).join(''),
    sections:sectionDirectory,stringCount:strings.length,
    codeBlocks:blocks.length};
}
export function hexView(bytes,limit=4096) {
  if(!(bytes instanceof Uint8Array))throw new TypeError('Expected BSBC binary bytes.');
  const slice=bytes.subarray(0,Math.min(bytes.length,limit));
  const lines=[];
  for(let i=0;i<slice.length;i+=16) {
    const line=Array.from(slice.subarray(i,i+16),byte=>byte.toString(16).padStart(2,'0')).join(' ');
    lines.push(i.toString(16).padStart(8,'0')+'  '+line);
  }
  if(bytes.length>slice.length)lines.push('... '+(bytes.length-slice.length)+' more bytes');
  return lines.join('\n');
}
function requireIndex(map,name,where) {
  const value=map.get(name);
  if(value===undefined)no('BSBC '+where+' is missing: '+name);
  return value;
}
