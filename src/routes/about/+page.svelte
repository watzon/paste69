<script lang="ts">
    import { Copy, DeviceFloppy, Moon, Sun, TextPlus } from 'svelte-tabler';
    import { storeHighlightJs } from '@skeletonlabs/skeleton';
    import { CodeBlock } from '@skeletonlabs/skeleton';
    import ToolBox from '$lib/components/ToolBox.svelte';
    import hljs from '$utils/hljs';
	import { goto } from '$app/navigation';

    storeHighlightJs.set(hljs);
</script>

<svelte:head>
    <title>Paste69 - About</title>
</svelte:head>

<div class="fixed bottom-0 right-0 w-full md:w-auto">
	<ToolBox disableSave={true} disableCopy={true} on:new={() => goto('/')} />
</div>

<div class="pl-2 pr-2 max-w-[100ch] pb-24">
	<h1 class="h1 mb-2">Paste69</h1>

	<p class="mb-4 mt-4">
		Paste69 is a pastebin service built with
		<a class="underline hover:text-gray-300" href="https://kit.svelte.dev">SvelteKit</a>. It's a simple, fast, and easy to use pastebin
		service based on HasteBin. Like HasteBin, it's also open source and can be found over on
		<a class="underline hover:text-gray-300" href="https://github.com/watzon/paste69">GitHub</a>.
	</p>

	<p class="mb-4 mt-4">
		Code highlighting is handled with the help of <a class="underline hover:text-gray-300" href="https://highlightjs.org/">highlight.js</a>.
		So if you have any issues with language detection or missing languages, take it up with them.
	</p>

	<h2 id="usage" class="h2 mt-4 mb-2"><a class="underline hover:text-gray-300" href="#usage">Usage</a></h2>

	<p class="mb-4 mt-4">
		To create a paste, go <a class="underline hover:text-gray-300" href="/">home</a> or click the "New" button (<TextPlus
			class="inline-block w-4 h-4"
		/>) in the tool box in the bottom right corner of the page. Paste whatever text you want into
		the editor, and click the "Save" button (<DeviceFloppy class="inline-block w-4 h-4" />) to
		create the paste.
	</p>

	<p class="mb-4 mt-4">
		To copy an existing paste, click the "Copy" button (<Copy class="inline-block w-4 h-4" />)
		in the tool box in the bottom right corner of the page. This will start a new paste with the
		contents of the existing paste.
	</p>

	<h2 id="cli-script" class="h2 mt-4 mb-2"><a class="underline hover:text-gray-300" href="#cli-script">CLI Script</a></h2>

	<p class="mb-4 mt-4">
		To make it easier to create pastes, a CLI script is available. The script can be found <a
			href="/paste69.sh">here</a
		>. To use the script:
	</p>

	<CodeBlock language="bash" code={`$ curl -O https://0x45.st/paste69.sh && chmod +x paste69.sh<br />
$ ./paste69.sh --help<br /><br />

Paste69 CLI script<br /><br />

Usage:<br />
paste69 &lt;file&gt; [options]<br />
cat &lt;file&gt; | paste69 [options]<br /><br />

Options:<br />
-h, --help                 Show this help text<br />
-r, --raw                  Return the raw JSON response<br />
-c, --copy                 Copy the paste URL to the clipboard<br />`}></CodeBlock>

	<p class="mb-4 mt-4">To create a paste with the script, simply pipe the contents of a file to the script:</p>

    <CodeBlock language="bash" code={`$ cat file.md | ./paste69.sh<br />
https://0x45.st/some-random-id.md`}></CodeBlock>

	<h2 id="api" class="h2 mt-4 mb-2"><a class="underline hover:text-gray-300" href="#api">API</a></h2>

	<p class="mb-4 mt-4">Paste69 has a simple API for creating and fetching pastes. The API is documented below.</p>

	<h3 id="api-creating-a-paste" class="h3 mt-4 mb-2">
		<a class="underline hover:text-gray-300" href="#api-creating-a-paste">Creating a Paste</a>
	</h3>

	<p class="mb-4 mt-4">
		To create a paste, send a POST request to <code>/api/pastes</code>
		{' '}
		with the following JSON body:
	</p>

    <CodeBlock language="json" code={`{ "contents": "paste contents" }`}></CodeBlock>

	<p class="mb-4 mt-4">If the paste was successfully created, the API will respond with the following JSON:</p>

    <CodeBlock language="json" code={`{
    "id": "paste id",
    "contents": "paste contents",
    "highlight": "txt",
    "created_at": "2021-08-05T07:30:00.000Z",
}`}></CodeBlock>

	<h3 id="api-fetching-a-paste" class="h3 mt-4 mb-2">
		<a class="underline hover:text-gray-300" href="#api-fetching-a-paste">Fetching a Paste</a>
	</h3>

	<p class="mb-4 mt-4">
		To fetch a paste, send a GET request to{' '}
		<code>/api/pastes/:id</code>. If the paste exists, the API will respond with the following JSON:
	</p>

    <CodeBlock language="json" code={`{
    "id": "paste id",
    "contents": "paste contents",
    "highlight": "txt",
    "created_at": "2021-08-05T07:30:00.000Z",
}`}></CodeBlock>
</div>