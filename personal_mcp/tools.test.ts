import {describe, it} from 'node:test';
import assert from 'node:assert';
import * as fs from 'node:fs/promises';
import * as os from 'node:os';
import * as path from 'node:path';
import {add_notes} from './tools.ts';

describe('add_notes tool', () => {
  it('appends notes to agent_notes.md in the current working directory', async () => {
    const previousCwd = process.cwd();
    const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'personal-mcp-notes-'));

    try {
      process.chdir(tempDir);
      const result = await add_notes({content: 'Remember the installer fix.'}, {});
      const content = result.content[0];

      assert.strictEqual(result.isError, false);
      assert.strictEqual(content.type, 'text');
      assert.strictEqual(content.text, '👍');

      const notes = await fs.readFile(path.join(tempDir, 'agent_notes.md'), 'utf8');
      assert.match(notes, /Remember the installer fix\./);
    } finally {
      process.chdir(previousCwd);
      await fs.rm(tempDir, {recursive: true, force: true});
    }
  });
});
