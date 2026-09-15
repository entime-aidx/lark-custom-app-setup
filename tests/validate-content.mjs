import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
const root = process.cwd();
function walk(dir) { return fs.readdirSync(dir, { withFileTypes: true }).flatMap(e => e.name === '.git' ? [] : e.isDirectory() ? walk(path.join(dir, e.name)) : [path.join(dir, e.name)]); }
for (const file of walk(root)) {
  if (file.endsWith('.json')) JSON.parse(fs.readFileSync(file, 'utf8'));
  if (file.endsWith('.md')) {
    const text = fs.readFileSync(file, 'utf8');
    for (const [, href] of text.matchAll(/\]\(([^)]+)\)/g)) {
      if (/^(https?:|#)/.test(href)) continue;
      assert.ok(fs.existsSync(path.resolve(path.dirname(file), href.split('#')[0])), `${path.relative(root, file)}: broken link ${href}`);
    }
  }
}
const manifest = JSON.parse(fs.readFileSync('.claude-plugin/marketplace.json'));
const plugin = JSON.parse(fs.readFileSync('.claude-plugin/plugin.json'));
assert.equal(manifest.name, 'entime-training');
assert.equal(manifest.plugins[0].version, plugin.version);
const original = JSON.parse(fs.readFileSync('skills/lark-custom-app-setup/scopes-larkapps-create.json'));
const training = JSON.parse(fs.readFileSync('skills/lark-custom-app-setup/scopes-training-base.json'));
assert.deepEqual(training.scopes.tenant, []);
for (const scope of training.scopes.user) {
  assert.ok(original.scopes.user.includes(scope), `unknown source scope: ${scope}`);
  assert.ok(!scope.includes('delete') && !scope.includes('collaborator') && !scope.includes('mail:') && !scope.includes('im:'), scope);
}
console.log('JSON, plugin metadata, local links and training scope checks passed.');
