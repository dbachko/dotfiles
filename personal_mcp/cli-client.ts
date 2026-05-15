import { get_unresolved_comments , fetchAsMarkdown, runGoogleAiSearch } from './tools.ts';

// const result = await runGoogleAiSearch({
//   query: 'what is the best way to cook salmon'
// });


// const result = await get_unresolved_comments({}, undefined);

const result = await fetchAsMarkdown({url: 'https://cascadiajs-2025.netlify.app/20-color-spaces/'});

if (result.isError) {
  const content = result.content[0];
  console.error('Error:', content.type === 'text' ? content.text : content);
} else {
  const content = result.content[0];
  console.log(content.type === 'text' ? content.text : content);
}
