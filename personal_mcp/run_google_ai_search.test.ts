import { test } from 'node:test';
import assert from 'node:assert';
import { runGoogleAiSearch } from './tools.ts'; // ts-node allows .ts extension
import * as fs from 'node:fs/promises';

test('run_google_ai_search works', { timeout: 60000 }, async (t) => {
  // Use a query that likely triggers AI overview or at least some complex result.
  // "how to center a div" is a classic.
  const query = 'how to center a div';
  
  console.log('Starting Google AI search test...');
  const result = await runGoogleAiSearch({ query });
  const content = result.content[0];
  assert.strictEqual(content.type, 'text');
  
  console.log('Result:', result);

  if (result.isError) {
      const message = content.text;
      if (message.includes('Failed to connect to browser')) {
        t.skip(`Missing browser with remote debugging enabled: ${message}`);
        return;
      }

      assert.fail(`Tool execution failed: ${message}`);
  }

  assert.ok(content.text.includes('Saved AI response'));
  
  // Check if file exists and cleanup
  const match = content.text.match(/Saved AI response to (.*?) \(source:/);
  if (match) {
      const fullPath = match[1];
      try {
          const stat = await fs.stat(fullPath);
          assert.ok(stat.isFile(), 'Output file should exist');
          console.log(`Verified file ${fullPath} exists.`);
          
          // Clean up
          await fs.unlink(fullPath);
          console.log(`Cleaned up ${fullPath}.`);
      } catch (e) {
          assert.fail(`File check failed: ${e.message}`);
      }
  } else {
      assert.fail('Could not parse filename from result message');
  }
});
