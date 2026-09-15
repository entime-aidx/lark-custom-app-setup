import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { assess, probeVersion } from '../skills/lark-custom-app-setup/scripts/preflight.mjs';
const machine = { platform: 'darwin', arch: 'arm64', release: '23.6.0', memory: 8 * 1024 ** 3, node: '22.0.0' };
const versions = { npm: '10.0.0', lark: '1.0.92', claude: '2.1.0', git: '2.40.0', bash: '5.2.0' };
test('supported local prerequisites pass, without claiming online verification', () => {
  const r = assess(machine, versions);
  assert.equal(r.ok, true);
  assert.equal(r.stage, 'local-prerequisites-only');
  assert.ok(r.notChecked.includes('Target Base permissions'));
});
test('each missing dependency fails; cli-only does not need Claude or Git', () => {
  for (const key of ['npm', 'lark', 'claude', 'git']) assert.equal(assess(machine, { ...versions, [key]: null }).ok, false);
  assert.equal(assess(machine, { npm: '10.0.0', lark: '1.0.92' }, true).ok, true);
});
test('old OS, Node, low RAM, and 32-bit CPU never pass', () => {
  for (const change of [{ release: '21.0.0' }, { node: '18.0.0' }, { memory: 2 * 1024 ** 3 }, { arch: 'ia32' }])
    assert.equal(assess({ ...machine, ...change }, versions).ok, false);
});
test('Windows checks minimum build and Bash', () => {
  const win = { ...machine, platform: 'win32', arch: 'x64', release: '10.0.22631' };
  assert.equal(assess(win, versions).ok, true);
  assert.equal(assess({ ...win, release: '10.0.17762' }, versions).ok, false);
  assert.equal(assess(win, { ...versions, bash: null }).ok, false);
});
test('Linux/WSL and unknown OS require manual OS verification', () => {
  for (const platform of ['linux', 'freebsd']) assert.equal(assess({ ...machine, platform }, versions).ok, false);
});
test('failed, timed out, or non-version output never passes', () => {
  for (const result of [{ status: 1, stdout: '1.0.0' }, { status: null, error: new Error('timeout') }, { status: 0, stdout: 'unrecognized command' }])
    assert.equal(probeVersion('lark', 'darwin', () => result), null);
});
test('version probe only returns version, not raw secret-like diagnostic output', () => {
  assert.equal(probeVersion('lark', 'darwin', () => ({ status: 0, stdout: 'lark-cli 1.0.92\nprivate diagnostic should not be shown' })), '1.0.92');
});
test('Windows uses fixed version commands; caller cannot inject command text', () => {
  let called;
  probeVersion('npm', 'win32', (...args) => { called = args; return { status: 0, stdout: '10.0.0' }; });
  assert.deepEqual(called[1], ['/d', '/s', '/c', 'npm --version']);
  assert.throws(() => probeVersion('npm & unwanted', 'win32'), /Unknown/);
});
test('npm version probing works on the actual CI host', () => {
  assert.match(probeVersion('npm'), /^\d+\.\d+/);
});
test('unsupported CLI argument returns 2 without probes', () => {
  const r = spawnSync(process.execPath, ['skills/lark-custom-app-setup/scripts/preflight.mjs', '--install'], { encoding: 'utf8' });
  assert.equal(r.status, 2);
  assert.match(r.stderr, /Unknown argument/);
});
