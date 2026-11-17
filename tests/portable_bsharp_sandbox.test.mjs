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
