import { test } from 'node:test';
import assert from 'node:assert';
import { fetchAsMarkdown } from './tools.ts';

test('fetchAsMarkdown works', { timeout: 30000 }, async (t) => {
  const url = 'https://example.com';
  
  console.log('Starting fetchAsMarkdown test...');
  const result = await fetchAsMarkdown({ url });
  const content = result.content[0];
  assert.strictEqual(content.type, 'text');
  
  console.log('Result content type:', typeof content.text);
  
  if (result.isError) {
      const message = content.text;
      if (
        message.includes('Executable doesn\'t exist') ||
        message.includes('Cannot find module') ||
        message.includes('pandoc')
      ) {
        t.skip(`Missing integration dependency: ${message}`);
        return;
      }

      assert.fail(`Tool execution failed: ${message}`);
  }

  const markdown = content.text;
  assert.ok(markdown && markdown.length > 0, 'Markdown should not be empty');
  assert.ok(markdown.includes('Example Domain'), 'Markdown should contain page title');
  
  console.log('Markdown snippet:', markdown.substring(0, 100));
});
