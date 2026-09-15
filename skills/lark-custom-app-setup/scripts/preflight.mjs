#!/usr/bin/env node
// Read-only: fixed version commands only; no credentials, network, or configuration writes.
import os from 'node:os';
import { spawnSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';

const COMMANDS = Object.freeze({ npm: 'npm', git: 'git', bash: 'bash', claude: 'claude', lark: 'lark-cli' });
export function probeVersion(key, platform = process.platform, runner = spawnSync) {
  const command = COMMANDS[key];
  if (!command) throw new Error('Unknown version probe');
  // npm/claude/lark may be .cmd shims on Windows. Only fixed commands enter cmd.exe.
  const result = platform === 'win32'
    ? runner(process.env.ComSpec || 'cmd.exe', ['/d', '/s', '/c', `${command} --version`], { encoding: 'utf8', timeout: 10000, windowsHide: true, maxBuffer: 65536 })
    : runner(command, ['--version'], { encoding: 'utf8', timeout: 10000, maxBuffer: 65536 });
  if (result.error || result.status !== 0) return null;
  // Do not expose arbitrary command output, paths, usernames, or diagnostics.
  return String(result.stdout || '').match(/\b\d+\.\d+(?:\.\d+)?\b/)?.[0] || null;
}
export function assess(machine, versions, cliOnly = false) {
  const checks = [];
  const add = (name, ok, detail) => checks.push({ name, status: ok ? 'PASS' : 'CHECK', detail });
  const { platform, arch, release, memory, node } = machine;
  add('CPU', ['x64', 'arm64'].includes(arch), arch);
  const parts = release.split('.').map(Number);
  const supportedOS = platform === 'darwin' ? parts[0] >= 22
    : platform === 'win32' ? (parts[0] > 10 || (parts[0] === 10 && parts[2] >= 17763)) : false;
  add('OS', supportedOS, `${platform} ${release}${platform === 'linux' ? ' — Linux/WSL distribution must be checked manually' : ''}`);
  add('Node.js', Number(node.split('.')[0]) >= 22, `${node} — training baseline: 22+`);
  add('npm', !!versions.npm, versions.npm || 'Not found or version check failed');
  add('Lark CLI', !!versions.lark, versions.lark || 'Not found or version check failed');
  if (!cliOnly) {
    add('RAM', memory >= 4 * 1024 ** 3, `${(memory / 1024 ** 3).toFixed(1)} GiB — minimum: 4`);
    add('Claude Code', !!versions.claude, versions.claude || 'Not found or version check failed');
    add('Git (plugin install)', !!versions.git, versions.git || 'Not found or version check failed');
    if (platform === 'win32') add('Bash (Windows guide)', !!versions.bash, versions.bash ? `${versions.bash} — confirm this is Git Bash, not WSL` : 'Git Bash not found');
  }
  return { stage: 'local-prerequisites-only', mode: cliOnly ? 'cli-only' : 'claude-skill', ok: checks.every(c => c.status === 'PASS'), checks,
    notChecked: ['Company software policy', 'Claude Code account/contract', 'Lark app approval and user authorization', 'Network/proxy access', 'Target Base permissions', 'Cross-user editing'] };
}
export function run(args = process.argv.slice(2)) {
  if (args.includes('--help')) {
    console.log('Usage: node preflight.mjs [--json] [--cli-only]\nRead-only PC check. No install, auth, network, or credential reads. Exit 0=local prerequisites pass, 1=check required, 2=invalid arguments.');
    return 0;
  }
  if (args.some(a => !['--json', '--cli-only'].includes(a))) {
    console.error('Unknown argument. Use --help.');
    return 2;
  }
  const cliOnly = args.includes('--cli-only');
  const keys = cliOnly ? ['npm', 'lark'] : ['npm', 'lark', 'claude', 'git', ...(process.platform === 'win32' ? ['bash'] : [])];
  const versions = Object.fromEntries(keys.map(key => [key, probeVersion(key)]));
  const result = assess({ platform: process.platform, arch: process.arch, release: os.release(), memory: os.totalmem(), node: process.versions.node }, versions, cliOnly);
  if (args.includes('--json')) console.log(JSON.stringify(result, null, 2));
  else {
    console.log('Lark CLI training — local prerequisites only');
    for (const c of result.checks) console.log(`[${c.status}] ${c.name}: ${c.detail}`);
    console.log('\nNOT CHECKED: ' + result.notChecked.join('; '));
    console.log(result.ok ? '\nPC prerequisites PASS. Continue with Lark authorization and Base verification.' : '\nCHECK REQUIRED. Resolve missing items before proceeding.');
  }
  return result.ok ? 0 : 1;
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) process.exitCode = run();
