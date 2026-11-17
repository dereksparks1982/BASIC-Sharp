// BASIC# portable compiler: independent, Ruby-free, intentionally bounded.
export class BSharpError extends Error {
  constructor(line,message){super('Line '+line+': '+message);this.line=line;this.name='BSharpError';}
}
const die=(line,message)=>{throw new BSharpError(line,message);};
const norm=s=>s.trim().replace(/\s+/gu,' ').toLowerCase();
const HEADS=new Set(['KINDS','DEFINE','START','WHEN','IF','OTHERWISE','CONTROLS','HOVER','CONTEXT']);
const BUILTIN=new Set(['thing','person','creature','animal','device','door','key','table','guard','weapon','object']);
const EVENT={attacks:'attack',takes:'take',examines:'examine',speaks:'speak',opens:'open',closes:'close',sounds:'sound',locks:'lock',unlocks:'unlock'};
const ACTIONS=new Set(['change','damage','increase','decrease','take','carry','drop','open','close','lock','unlock','attack','examine','sound','speak','give','eat','wear','remove']);

export function read(source) {
  if(typeof source!=='string')throw new TypeError('BASIC# expects source text');
  let text='',comment=false,quote=false,line=1,begin=0;
  for(let i=0;i<source.length;i++){
    const ch=source[i],pair=source.slice(i,i+2);
    if(comment){
      if(pair==='//')die(line,'Comments cannot nest.');
      if(pair==='/.'){comment=false;text+='  ';i++;continue;}
      text+=ch==='\n'?'\n':' ';
      if(ch==='\n')line++;
      continue;
    }
    if(!quote&&pair==='/.')die(line,'Unmatched comment closing marker /.');
    if(!quote&&pair==='//'){comment=true;begin=line;text+='  ';i++;continue;}
    if(ch==='"')quote=!quote;
    if(ch==='\n'){line++;quote=false;}
    text+=ch;
  }
  if(comment)die(begin,'Unclosed // comment. Add /.');
  return text.split(/\r?\n/u).map((s,i)=>({line:i+1,text:s.trim()})).filter(r=>r.text);
}
export function blocks(source){
  const output=[];let current=null,open=false;
  for(const r of read(source)){
    if(!current){
      const m=/^([A-Z]+)(?:\s+(.+))?$/u.exec(r.text);
      if(!m||!HEADS.has(m[1]))die(r.line,'Expected a known BASIC# Head.');
      if(['WHEN','IF','CONTROLS','HOVER','CONTEXT'].includes(m[1])&&!m[2])die(r.line,m[1]+' needs a description.');
      if(['KINDS','DEFINE','START','OTHERWISE'].includes(m[1])&&m[2])die(r.line,m[1]+' accepts no Head detail.');
      current={head:m[1],detail:m[2]||'',line:r.line,body:[]};open=true;continue;
    }
    if(open){if(r.text!=='[')die(r.line,'Body must begin with [');open=false;continue;}
    if(r.text==='].'){output.push(current);current=null;continue;}
    if(r.text===']')die(r.line,'Body must end with ].');
    if(/^(KINDS|DEFINE|START|WHEN|IF|OTHERWISE|CONTROLS|HOVER|CONTEXT)(?:\s|$)/u.test(r.text))die(r.line,'Missing ]. before next Head.');
    current.body.push(r);
  }
  if(current)die(current.line,'Unterminated '+current.head+' Body.');
  return output;
}
const state=s=>({kind:'state',name:norm(s)});
function reference(input,items,line){
  if(input.trim()==='PLAYER')return{type:'object',text:'player',name:'player',object_kind:'person'};
  if(!input.trim().startsWith('@'))die(line,'Use @Thing or PLAYER in the independent compiler.');
  const name=norm(input.trim().slice(1)),obj=items.get(name);
  if(!obj)die(line,'Unknown Thing @'+name+'.');
  return{type:'object',text:name,name,object_kind:obj.kind};
}
function atomic(s,items,line,condition=false){
  let m=/^(.+?)\s+has\s+(\d+)\s+([a-z][a-z0-9]*)$/iu.exec(s);
  if(m){
    const n=Number(m[2]);
    if(!Number.isSafeInteger(n)||n>2147483647)die(line,'Invalid whole number.');
    const data={subject:reference(m[1],items,line),relation:'has',value_name:norm(m[3]),amount:n};
    return condition?{raw:norm(s.replace(/@(?=\w)/gu,'')),...data}:
      {line_number:line,...data,raw:{subject:norm(m[1].replace(/^@/u,'')),relation:'has',value:m[2]+' '+norm(m[3]),line_number:line}};
  }
  m=/^(.+?)\s+(is|isnt)\s+([a-z][a-z0-9 -]*)$/iu.exec(s);
  if(!m)die(line,'Expected @Thing is state or PLAYER has 3 health.');
  if(!condition&&m[2].toLowerCase()!=='is')die(line,'START requires is, not isnt.');
  const data={subject:reference(m[1],items,line),relation:m[2].toLowerCase(),value:state(m[3])};
  return condition?{raw:norm(s.replace(/@(?=\w)/gu,'')),...data}:
    {line_number:line,...data,raw:{subject:norm(m[1].replace(/^@/u,'')),relation:'is',value:norm(m[3]),line_number:line}};
}
export function parseCondition(input,items,line){
  const parts=[],joiners=[];let quote=false,start=0;
  for(let i=0;i<input.length;i++){
    if(input[i]==='"')quote=!quote;
    if(quote)continue;
    const m=/^(and|or)(?=\s|$)/iu.exec(input.slice(i));
    if(m&&(i===0||/\s/u.test(input[i-1]))){
      parts.push(input.slice(start,i).trim());joiners.push(m[1].toLowerCase());
      i+=m[1].length-1;start=i+1;
    }
  }
  parts.push(input.slice(start).trim());
  if(parts.some(x=>!x))die(line,'An IF connector needs complete conditions on both sides.');
  if(new Set(joiners).size>1)die(line,'Do not mix and and or in one IF.');
  const result=parts.map(p=>atomic(p,items,line,true));
  return joiners.length?{raw:result.map(x=>x.raw).join(' '+joiners[0]+' '),connector:joiners[0],clauses:result}:result[0];
}
function action(text,items,line){
  const m=/^\|then\s+\(([a-z]+)\s+(.+)$/iu.exec(text);
  if(!m)die(line,'Use |then (action to describe an action.');
  const word=m[1].toLowerCase(),tail=m[2].trim();
  if(!ACTIONS.has(word))die(line,'Unknown action ('+word+'.');
  if(word==='change'){
    const p=/^(.+?)\s+to\s+([a-z][a-z0-9 -]*)$/iu.exec(tail);
    if(!p)die(line,'Use (change @Thing to state.');
    return{line_number:line,action:word,target:reference(p[1],items,line),to:state(p[2])};
  }
  if(word==='increase'||word==='decrease'){
    const p=/^([a-z][a-z0-9]*)\s+of\s+(.+?)\s+by\s+(\d+)$/iu.exec(tail);
    if(!p)die(line,'Use ('+word+' score of PLAYER by 1.');
    return{line_number:line,action:word,value_name:norm(p[1]),target:reference(p[2],items,line),amount:Number(p[3])};
  }
  if(word==='damage'){
    const p=/^(.+?)(?:\s+by\s+(\d+))?$/iu.exec(tail);
    return{line_number:line,action:word,target:reference(p[1],items,line),amount:p[2]?Number(p[2]):1};
  }
  return{line_number:line,action:word,target:reference(tail,items,line)};
}
function event(text,items,line){
  const m=/^(.+?)\s+([a-z]+)\s+(.+)$/iu.exec(text);
  if(!m||!EVENT[m[2].toLowerCase()])die(line,'WHEN needs a supported event and target.');
  return{raw:norm(text.replace(/@(?=\w)/gu,'')),actor:reference(m[1],items,line),
    action:EVENT[m[2].toLowerCase()],target:reference(m[3],items,line)};
}
export function compile(source,{version='0.0.84'}={}){
  const sourceBlocks=blocks(source),names=new Set(BUILTIN),kinds=[];
  const player={name:'player',kind:'person',builtin:true,line_number:null};
  const objects=[player],known=new Map([['player',player]]);
  for(const b of sourceBlocks.filter(x=>x.head==='KINDS'))for(const r of b.body){
    const m=/^#(.+?)\s+is\s+a\s+#(.+)$/iu.exec(r.text);
    if(!m)die(r.line,'Use #Kind is a #Parent.');
    const name=norm(m[1]),parent=norm(m[2]);
    if(!names.has(parent))die(r.line,'Unknown parent Kind #'+parent+'.');
    if(names.has(name))die(r.line,'Duplicate Kind #'+name+'.');
    kinds.push({name,parent,line_number:r.line});names.add(name);
  }
  for(const b of sourceBlocks.filter(x=>x.head==='DEFINE'))for(const r of b.body){
    const m=/^@(.+?)\s+is\s+a\s+#(.+)$/iu.exec(r.text);
    if(!m)die(r.line,'Use @Thing is a #Kind.');
    const name=norm(m[1]),kind=norm(m[2]);
    if(!names.has(kind))die(r.line,'Unknown Kind #'+kind+'.');
    if(known.has(name))die(r.line,'Duplicate Thing @'+name+'.');
    const obj={name,kind,builtin:false,line_number:r.line};objects.push(obj);known.set(name,obj);
  }
  const ir={version,format:'bsir.debug.json',kinds,objects,facts:[],events:[],if_rules:[],
    controls:[],hover_declarations:[],context_declarations:[],diagnostics:[]};
  let profile=1,previous=null;
  for(const b of sourceBlocks){
    if(b.head==='KINDS'||b.head==='DEFINE'){previous=null;continue;}
    if(b.head==='START'){
      for(const r of b.body){const f=atomic(r.text,known,r.line);ir.facts.push(f);if(f.relation==='has')profile=Math.max(profile,5);}
      previous=null;continue;
    }
    if(b.head==='WHEN'){
      const then=b.body.map(r=>action(r.text,known,r.line));
      ir.events.push({line_number:b.line,when:event(b.detail,known,b.line),then});
      if(then.some(a=>a.action==='increase'||a.action==='decrease'))profile=Math.max(profile,5);
      previous=null;continue;
    }
    if(b.head==='IF'){
      const condition=parseCondition(b.detail,known,b.line),then=b.body.map(r=>action(r.text,known,r.line));
      if(condition.connector)profile=Math.max(profile,6);
      if(condition.amount!==undefined||(condition.clauses||[]).some(c=>c.amount!==undefined))profile=Math.max(profile,5);
      previous={line_number:b.line,if:condition,then};ir.if_rules.push(previous);continue;
    }
    if(b.head==='OTHERWISE'){
      if(!previous)die(b.line,'OTHERWISE must directly follow IF.');
      previous.otherwise_line_number=b.line;
      previous.otherwise=b.body.map(r=>action(r.text,known,r.line));
      profile=7;previous=null;continue;
    }
    die(b.line,b.head+' is not yet supported by this Ruby-free compiler. No Ruby fallback was used.');
  }
  if(profile>1)ir.meaning_profile='bsharp.meaning.v'+profile;
  return ir;
}
