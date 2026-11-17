// Future browser sandbox regression suite. Not run during source-only development.
import test from 'node:test';
import assert from 'node:assert/strict';
import {compile} from '../compiler/portable/bsharp_compiler.mjs';
import {BSharpSandbox, SandboxError} from '../compiler/portable/bsharp_sandbox.mjs';

const program = [
  'DEFINE','[',' @lamp is a #device',' @switch is a #device','].',
  'START','[',' @lamp is off',' PLAYER has 0 points','].',
  'WHEN PLAYER attacks @switch','[',' |then (change @lamp to on','].',
  'WHEN PLAYER speaks @switch','[',' |then (change @lamp to off','].',
  'IF @lamp is on','[',' |then (increase points of PLAYER by 1','].'
].join('\n');

test('START and WHEN events execute without Ruby', () => {
  const sim = new BSharpSandbox(compile(program));
  assert.equal(sim.snapshot().find(x => x.name === 'lamp').states[0], 'off');
  sim.runEvent(0);
  assert.equal(sim.snapshot().find(x => x.name === 'lamp').states[0], 'on');
  assert.equal(sim.snapshot().find(x => x.name === 'player').values.points, 1);
  sim.runEvent(1);
  sim.runEvent(0);
  assert.equal(sim.snapshot().find(x => x.name === 'player').values.points, 2);
});

test('reactive IF without OTHERWISE wakes once, then rearms', () => {
  const sim = new BSharpSandbox(compile(program));
  sim.runEvent(0);
  sim.runEvent(0);
  assert.equal(sim.snapshot().find(x => x.name === 'player').values.points, 1);
  sim.runEvent(1);
  sim.runEvent(0);
  assert.equal(sim.snapshot().find(x => x.name === 'player').values.points, 2);
});

test('OTHERWISE executes on START when IF is false', () => {
  const source = [
    'DEFINE','[',' @lamp is a #device','].',
    'START','[',' @lamp is off',' PLAYER has 0 points','].',
    'IF @lamp is on','[',' |then (change @lamp to off','].',
    'OTHERWISE','[',' |then (increase points of PLAYER by 1','].'
  ].join('\n');
  const sim = new BSharpSandbox(compile(source));
  assert.equal(sim.snapshot().find(x => x.name === 'player').values.points, 1);
});

test('unsupported actions never silently simulate', () => {
  const source = [
    'DEFINE','[',' @lamp is a #device','].',
    'WHEN PLAYER attacks @lamp','[',' |then (attack @lamp','].'
  ].join('\n');
  assert.throws(() => new BSharpSandbox(compile(source)), SandboxError);
});

test('numeric comparisons and compound IFs execute in the browser sandbox',()=>{
 const src='DEFINE\n[\n @boss is a #creature\n].\nSTART\n[\n PLAYER has 90 score\n PLAYER has 0 victories\n @boss is dead\n].\nWHEN PLAYER attacks @boss\n[\n |then (increase score of PLAYER by 10\n].\nIF PLAYER has at least 100 score and @boss is dead\n[\n |then (increase victories of PLAYER by 1\n].';
 const sim=new BSharpSandbox(compile(src));
 assert.equal(sim.snapshot().find(x=>x.name==='player').values.victories,0);
 sim.runEvent(0);
 assert.equal(sim.snapshot().find(x=>x.name==='player').values.victories,1);
});
test('text values compare with exact characters and update on WHEN',()=>{
 const src='DEFINE\n[\n @door is a #door\n].\nSTART\n[\n @door has "Closed" title\n].\nWHEN PLAYER opens @door\n[\n |then (change title of @door to "Open"\n].\nIF @door has "Open" title\n[\n |then (change @door to open\n].';
 const sim=new BSharpSandbox(compile(src));
 sim.runEvent(0);
 const door=sim.snapshot().find(x=>x.name==='door');
 assert.equal(door.values.title,'Open');
 assert.deepEqual(door.states,['open']);
});
test('direct object-interaction actions change canonical world state',()=>{
 const src='DEFINE\n[\n @door is a #door\n @key is a #key\n].\nSTART\n[\n @door is closed\n].\nWHEN PLAYER takes @key\n[\n |then (take @key\n |then (open @door\n].';
 const sim=new BSharpSandbox(compile(src));
 sim.runEvent(0);
 assert.equal(sim.snapshot().find(x=>x.name==='key').relations['carried by'],'player');
 assert.deepEqual(sim.snapshot().find(x=>x.name==='door').states,['open']);
});


test('one WHEN Kind rule applies to inherited and direct member Things',()=>{
 const source=[
  'KINDS','[',' #monster is a #creature','].',
  'DEFINE','[',' @goblin is a #monster',' @wolf is a #creature',' @door is a #door','].',
  'WHEN PLAYER attacks a #creature','[',' |then (damage it by 2','].'
 ].join('\n');
 const sim=new BSharpSandbox(compile(source));
 const opts=sim.eventOptions();
 assert(opts.some(x=>x.target==='goblin'));
 assert(opts.some(x=>x.target==='wolf'));
 assert(!opts.some(x=>x.target==='door'));
 sim.runEventText('PLAYER attacks @goblin');
 sim.runEventText('PLAYER attacks @wolf');
 const world=sim.snapshot();
 assert.equal(world.find(x=>x.name==='goblin').values.damage,2);
 assert.equal(world.find(x=>x.name==='wolf').values.damage,2);
 assert.equal(world.find(x=>x.name==='door').values.damage,0);
});
test('typed event selects exact rule ahead of generic #Kind rule',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature',' @wolf is a #creature','].',
  'WHEN PLAYER attacks a #creature','[',' |then (damage it by 2','].',
  'WHEN PLAYER attacks @goblin','[',' |then (damage @goblin by 5','].'
 ].join('\n');
 const sim=new BSharpSandbox(compile(source));
 sim.runEventText('PLAYER attacks @goblin');
 sim.runEventText('PLAYER attacks @wolf');
 assert.equal(sim.snapshot().find(x=>x.name==='goblin').values.damage,5);
 assert.equal(sim.snapshot().find(x=>x.name==='wolf').values.damage,2);
});
test('typed event fails closed for unmatched Kind and unknown Things',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature',' @door is a #door','].',
  'WHEN PLAYER attacks a #creature','[',' |then (damage it','].'
 ].join('\n');
 const sim=new BSharpSandbox(compile(source));
 assert.throws(()=>sim.runEventText('PLAYER attacks @door'),SandboxError);
 assert.throws(()=>sim.runEventText('PLAYER attacks @dragon'),SandboxError);
 assert.equal(sim.snapshot().find(x=>x.name==='goblin').values.damage,0);
});
test('named-object it resolves to its established WHEN object',()=>{
 const source=[
  'DEFINE','[',' @goblin is a #creature','].',
  'WHEN PLAYER speaks @goblin','[',' |then (damage it by 3','].'
 ].join('\n');
 const sim=new BSharpSandbox(compile(source));
 sim.runEventText('PLAYER speaks @goblin');
 assert.equal(sim.snapshot().find(x=>x.name==='goblin').values.damage,3);
});


test('event chooser shows one action when a specific WHEN overrides a Kind rule',()=>{
 const src=[
  'DEFINE','[',' @goblin is a #creature',' @wolf is a #creature','].',
  'WHEN PLAYER attacks a #creature','[',' |then (damage it by 2','].',
  'WHEN PLAYER attacks @goblin','[',' |then (damage @goblin by 5','].'
 ].join('\n');
 const sim=new BSharpSandbox(compile(src));
 const selected=sim.eventOptions().filter(x=>x.actor==='player'&&x.target==='goblin');
 assert.equal(selected.length,1);
 assert.equal(selected[0].index,1);
 sim.runEvent(selected[0].index,selected[0]);
 assert.equal(sim.snapshot().find(x=>x.name==='goblin').values.damage,5);
});
