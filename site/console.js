import {compile} from '../compiler/portable/bsharp_compiler.mjs';
import {BSharpSandbox} from '../compiler/portable/bsharp_sandbox.mjs';
import {encodeBSBC, hexView} from '../compiler/portable/bsharp_bsbc_encoder.mjs';
import {loadBSBC} from '../compiler/portable/bsharp_bsbc_loader.mjs';
import {BSharpBytecodeVM} from '../compiler/portable/bsharp_bsbc_vm.mjs';

const examples = {
  alarm: [
    'DEFINE', '[', '    @bell is a #device', '    @gate is a #door',
    '    @guard one is a #guard', '    @guard two is a #guard', '].', '',
    'START', '[', '    @gate is locked',
    '    @guard one is calm', '    @guard two is calm', '].', '',
    'WHEN PLAYER sounds @bell', '[',
    '    |then (change every #guard to angry',
    '    |then (cause @guard one opens @gate', '].', '',
    'WHEN @guard one opens @gate', '[',
    '    |then (open @gate',
    '    |then (cause @guard two attacks PLAYER', '].', '',
    'WHEN @guard two attacks PLAYER', '[',
    '    |then (damage PLAYER by 3', '].', ''
  ].join('\n'),
  creatures: [
    'KINDS', '[', '    #monster is a #creature', '].', '',
    'DEFINE', '[', '    @goblin is a #monster', '    @wolf is a #creature', '].', '',
    'START', '[', '    @goblin is alive', '    @wolf is alive', '].', '',
    'WHEN PLAYER attacks a #creature', '[',
    '    |then (damage it by 2', '    |then (change it to dead', '].', '',
    'WHEN PLAYER speaks @goblin', '[',
    '    |then (change it to alive', '].', ''
  ].join('\n'),
  lamp: [
    'DEFINE', '[', '    @lamp is a #device', '    @switch is a #device', '].', '',
    'START', '[', '    @lamp is off', '    PLAYER has 0 points', '].', '',
    'WHEN PLAYER attacks @switch', '[',
    '    |then (change @lamp to on', '].', '',
    'WHEN PLAYER speaks @switch', '[',
    '    |then (change @lamp to off', '].', '',
    'IF @lamp is on', '[',
    '    |then (increase points of PLAYER by 1', '].', ''
  ].join('\n'),
  guard: [
    'DEFINE', '[', '    @guard is a #creature', '    @sword is a #weapon', '].', '',
    'START', '[', '    @guard is alive', '    PLAYER has 0 victories', '].', '',
    'WHEN PLAYER attacks @guard', '[',
    '    |then (damage @guard by 3', '    |then (change @guard to dead', '].', '',
    'WHEN PLAYER speaks @guard', '[',
    '    |then (change @guard to alive', '].', '',
    'IF @guard is dead', '[',
    '    |then (increase victories of PLAYER by 1', '].', ''
  ].join('\n'),
  thresholds: [
    'DEFINE', '[', '    @boss is a #creature', '    @bridge is a #thing', '    @coin is a #thing', '].', '',
    'START', '[', '    PLAYER has 0 score', '    PLAYER has 0 victories',
    '    @boss is alive', '    @bridge is whole', '].', '',
    'WHEN PLAYER takes @coin', '[', '    |then (increase score of PLAYER by 50', '].', '',
    'WHEN PLAYER attacks @boss', '[', '    |then (change @boss to dead', '].', '',
    'WHEN PLAYER speaks @boss', '[', '    |then (change @boss to alive', '].', '',
    'IF PLAYER has at least 100 score and @boss is dead', '[',
    '    |then (increase victories of PLAYER by 1', '].', '',
    'IF PLAYER has less than 25 score or @bridge is broken', '[',
    '    |then (damage PLAYER', '].', ''
  ].join('\n'),
  titles: [
    'KINDS', '[', '    #gate is a #door', '].', '',
    'DEFINE', '[', '    @north gate is a #gate', '    @brass bell is a #device', '].', '',
    'START', '[', '    @north gate has "North Gate" title', '    @north gate is closed', '].', '',
    'WHEN PLAYER sounds @brass bell', '[',
    '    |then (change title of @north gate to "Welcome, traveller!"',
    '    |then (open the #gate', '].', '',
    'WHEN PLAYER closes @north gate', '[',
    '    |then (change title of @north gate to "North Gate"',
    '    |then (close @north gate', '].', '',
    'IF @north gate has "Welcome, traveller!" title', '[',
    '    |then (damage PLAYER', '].', ''
  ].join('\n'),
  door: [
    'DEFINE', '[', '    @door is a #door', '    @key is a #key', '].', '',
    'START', '[', '    @door is locked', '].', '',
    'WHEN PLAYER takes @key', '[',
    '    |then (carry @key', '    |then (unlock @door', '].', '',
    'WHEN PLAYER opens @door', '[',
    '    |then (change @door to open', '].', '',
    'IF @door is open', '[',
    '    |then (damage PLAYER', '].', ''
  ].join('\n')
};
const get = id => document.getElementById(id);
const editor = get('source'), select = get('examples'), log = get('log'), events = get('events');
const status = get('status'), world = get('world'), irBox = get('ir'), bsbcBox = get('bsbc');
let sandbox = null, compiled = null, lastLogIndex = 0, runSerial = 0, activeEngine = null;
const storageKey = 'bsharp.console.source.v1';

function remember() {
  try {localStorage.setItem(storageKey, editor.value);} catch (_) { /* Private browsing can block storage. */ }
}
function setStatus(message, type) {
  status.textContent = message;
  status.className = 'status ' + type;
}
function appendTrace() {
  if (!sandbox) return;
  const newLines = sandbox.trace.slice(lastLogIndex);
  if (newLines.length) {
    if (log.textContent === 'No program has been executed yet.') log.textContent = '';
    log.textContent += (log.textContent ? '\n' : '') + newLines.join('\n');
    log.scrollTop = log.scrollHeight;
    lastLogIndex = sandbox.trace.length;
  }
}
function createText(tag, text, className) {
  const element = document.createElement(tag);
  element.textContent = text;
  if (className) element.className = className;
  return element;
}
function updateWorld() {
  world.replaceChildren();
  if (!sandbox) {
    world.append(createText('p', 'Execute a program to inspect its world.', 'placeholder'));
    return;
  }
  for (const item of sandbox.snapshot()) {
    const card = createText('article', '', 'thing');
    card.append(createText('h3', item.name), createText('small', item.kind + (item.builtin ? ' · built in' : '')));
    const details = document.createElement('dl');
    function field(label, value) {
      details.append(createText('dt', label), createText('dd', value));
    }
    field('States', item.states.length ? item.states.join(', ') : 'none');
    const values = Object.entries(item.values).filter(([key, value]) => key !== 'damage' || value !== 0);
    field('Values', values.length ? values.map(([key, value]) => key + ': ' + value).join(' · ') : 'none');
    const relations = Object.entries(item.relations);
    if (relations.length) field('Relations', relations.map(([key, value]) => key + ' ' + value).join(' · '));
    card.append(details);
    world.append(card);
  }
}
function updateEvents() {
  events.replaceChildren();
  if (!sandbox) {
    events.append(createText('span', 'Execute a program to see available events.', 'placeholder'));
    return;
  }
  const options = sandbox.eventOptions();
  if (!options.length) {
    events.append(createText('span', 'No WHEN events declared.', 'placeholder'));
  }
  for (const entry of options) {
    const button = createText('button', '▶ ' + entry.label, 'event');
    button.type = 'button';
    button.addEventListener('click', () => {
      try {
        sandbox.runEvent(entry.index,entry);
        appendTrace();
        updateWorld();
        setStatus('Event executed', 'ok');
      } catch (error) {
        appendTrace();
        log.textContent += '\nERROR: ' + error.message;
        setStatus('Execution stopped', 'error');
        sandbox = null;
        get('reset').disabled = true;
        get('view-ir').disabled = true;
        get('view-bsbc').disabled = true;
        get('run-event').disabled = true;
        updateEvents();
      }
    });
    events.append(button);
  }
}
async function execute(mode = 'ir') {
  const serial=++runSerial,source=editor.value;
  remember();
  sandbox=null;compiled=null;activeEngine=null;lastLogIndex=0;
  for(const id of ['reset','view-ir','view-bsbc','run-event','execute','execute-bsbc'])
    get(id).disabled=true;
  irBox.hidden=true;
  bsbcBox.hidden=true;
  bsbcBox.textContent='';
  get('view-bsbc').textContent='Inspect BSBC';
  get('view-ir').textContent='Show BSharp IR';
  log.textContent='';
  setStatus(mode==='bsbc' ? 'Preparing BSBC execution…' : 'Reading BASIC#…','idle');
  try {
    const ir=compile(source);
    let vm;
    if(mode==='bsbc') {
      const artifact=await encodeBSBC(ir);
      // Constructor is a strict loader boundary: it takes binary, not IR.
      vm=new BSharpBytecodeVM(artifact.bytes,{expectedFingerprint:artifact.fingerprint});
    } else {
      vm=new BSharpSandbox(ir);
    }
    if(serial!==runSerial||editor.value!==source) {
      if(serial===runSerial) {
        log.textContent='Source changed during execution preparation. Press Execute again.';
        setStatus('Source changed', 'idle');
      }
      return;
    }
    compiled=ir;
    sandbox=vm;
    activeEngine=mode;
    for(const id of ['reset','view-ir','view-bsbc','run-event'])get(id).disabled=false;
    irBox.textContent=JSON.stringify(compiled,null,2);
    appendTrace();updateEvents();updateWorld();
    setStatus(mode==='bsbc' ? vm.program.profile+' VM running' : 'Browser IR sandbox running','ok');
  } catch(error) {
    if(serial!==runSerial)return;
    sandbox=null;compiled=null;activeEngine=null;
    log.textContent='ERROR: '+(error.message||String(error))+
      (mode==='bsbc' ? '\n\nThe bytecode VM supports Profiles 1 and 2 only. No fallback occurred.' : '');
    updateEvents();updateWorld();
    setStatus('Compilation or execution stopped','error');
  } finally {
    if(serial===runSerial) {
      get('execute').disabled=false;
      get('execute-bsbc').disabled=false;
    }
  }
}
get('execute').addEventListener('click',()=>{void execute('ir');});
get('execute-bsbc').addEventListener('click',()=>{void execute('bsbc');});
function runTypedEvent() {
  if (!sandbox) return;
  const value=get('event-input').value.trim();
  if (!value) {
    setStatus('Enter an event', 'error');
    return;
  }
  try {
    sandbox.runEventText(value);
    appendTrace();
    updateWorld();
    setStatus('Event executed', 'ok');
  } catch (error) {
    appendTrace();
    log.textContent += '\nERROR: ' + (error.message || String(error));
    setStatus('Event not executed', 'error');
    // Keep the current world inspectable. Reset remains available if a rule failed.
  }
}
get('run-event').addEventListener('click', runTypedEvent);
get('event-input').addEventListener('keydown', event => {
  if(event.key==='Enter') {event.preventDefault();runTypedEvent();}
});
get('reset').addEventListener('click', () => {
  if (!sandbox) return;
  try {
    sandbox.reset();
    lastLogIndex = 0;
    log.textContent = '';
    appendTrace();
    updateWorld();
    setStatus(activeEngine==='bsbc' ? 'BSBC world reset' : 'World reset', 'ok');
  } catch(error) {
    log.textContent += '\nERROR: ' + error.message;
    setStatus('Reset stopped', 'error');
    sandbox = null;
    get('reset').disabled = true;
    get('run-event').disabled = true;
    activeEngine = null;
    updateEvents();
  }
});
get('restore').addEventListener('click', () => {
  editor.value = examples[select.value];
  remember();
  setStatus('Example restored', 'idle');
});
select.addEventListener('change', () => {
  editor.value = examples[select.value];
  remember();
  setStatus('Example loaded', 'idle');
});
editor.addEventListener('input', remember);
editor.addEventListener('keydown', event => {
  if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
    event.preventDefault();
    void execute('ir');
  }
});
get('clear-log').addEventListener('click', () => {log.textContent = ''; if (sandbox) lastLogIndex = sandbox.trace.length;});
get('view-ir').addEventListener('click', () => {
  if (!compiled) return;
  irBox.hidden = !irBox.hidden;
  get('view-ir').textContent = irBox.hidden ? 'Show BSharp IR' : 'Hide BSharp IR';
});
try {editor.value = localStorage.getItem(storageKey) || examples.lamp;} catch (_) {editor.value = examples.lamp;}

get('view-bsbc').addEventListener('click', async () => {
  if(!compiled) return;
  if(!bsbcBox.hidden) {
    bsbcBox.hidden = true;
    get('view-bsbc').textContent = 'Inspect BSBC';
    return;
  }
  bsbcBox.hidden = false;
  get('view-bsbc').textContent = 'Hide BSBC';
  bsbcBox.textContent = 'Preparing BSBC bytes for inspection...';
  const snapshot = compiled;
  try {
    const artifact = await encodeBSBC(snapshot);
    if(compiled!==snapshot) return;
    // Inspect only bytes that survive the independent strict binary parser.
    // A matching fingerprint does not itself make unknown binary code executable.
    const loaded = loadBSBC(artifact.bytes,{expectedFingerprint:artifact.fingerprint});
    if(compiled!==snapshot) return;
    const table = loaded.sections.map(section =>
      section.id.padEnd(4)+'  offset '+String(section.offset).padStart(6)+
      '  bytes '+String(section.length).padStart(6)+
      '  records '+section.count
    ).join('\n');
    bsbcBox.textContent = 'BSharp Bytecode · '+loaded.profile+
      '\nValidation: '+loaded.validation+
      '\nFingerprint matched source: yes'+
      '\nFingerprint: '+loaded.fingerprint+
      '\nTotal bytes: '+loaded.byteLength+
      '\nStrings: '+loaded.strings.length+
      ' · Kinds: '+loaded.kinds.length+
      ' · Things: '+loaded.things.length+
      ' · Code blocks: '+loaded.blocks.length+
      ' · Instructions: '+loaded.instructionCount+
      '\n\nSECTIONS\n'+table+
      '\n\nBINARY HEX (first 4096 bytes)\n'+hexView(artifact.bytes);
  } catch(error) {
    if(compiled!==snapshot) return;
    bsbcBox.textContent = 'BSBC emission or validation stopped:\n'+error.message+
      '\n\nOnly the independent Profile 1/2 emitter and loader are implemented. No bytes were executed.';
  }
});
