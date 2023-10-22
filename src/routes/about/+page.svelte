<script lang="ts">
    import { ChevronDown, ChevronRight, ChevronUp, Copy, DeviceFloppy, InfoCircleFilled, Moon, Sun, TextPlus } from 'svelte-tabler';
    import { storeHighlightJs } from '@skeletonlabs/skeleton';
    import { CodeBlock } from '@skeletonlabs/skeleton';
    import ToolBox from '$lib/components/ToolBox.svelte';
    import hljs from '$utils/hljs';
	import { extensionMap } from '$utils/languages';
	import { goto } from '$app/navigation';

    storeHighlightJs.set(hljs);

	let showLanguages = false;

	const toggleLanguages = () => {
		showLanguages = !showLanguages;
	};

	// Split languages into four columns.
	const languages = Object.entries(extensionMap).reduce((acc, [language, extensions], i) => {
		const column = Math.floor(i / Math.ceil(Object.entries(extensionMap).length / 5));
		acc[column] = acc[column] || [] as { language: string, extensions: string[] }[];
		acc[column].push({ language, extensions: extensions.map(ext => `.${ext}`) });
		return acc;
	}, [] as { language: string, extensions: string[] }[][]);
</script>

<svelte:head>
    <title>Paste69 - About</title>
</svelte:head>

<div class="absolute top-[23px] left-[5px]">
	<ChevronRight />
</div>

<div class="pl-12 pt-4 pb-24 max-w-[100ch]">
	<h1 class="h1 mb-2">Paste69</h1>

	<p class="mb-6 mt-6">
		Paste69 is a pastebin service built with
		<a class="underline hover:text-gray-300" href="https://kit.svelte.dev">SvelteKit</a>. It's a simple, fast, and easy to use pastebin
		service based on HasteBin. Like HasteBin, it's also open source and can be found over on
		<a class="underline hover:text-gray-300" href="https://github.com/watzon/paste69">GitHub</a>.
	</p>

	<p class="mb-6 mt-6">
		Code highlighting is handled with the help of <a class="underline hover:text-gray-300" href="https://highlightjs.org/">highlight.js</a>.
		So if you have any issues with language detection or missing languages, take it up with them. Available languages (with their
		extensions) are as follows:
		<button
			class="inline-block ml-2 px-2"
			on:click={toggleLanguages}
		>
			{showLanguages ? 'Hide' : 'Show'} Languages
			{#if showLanguages}
				<ChevronUp class="inline-block w-4 h-4" />
			{:else}
				<ChevronDown class="inline-block w-4 h-4" />
			{/if}
	</button>
	</p>

	{#if showLanguages}
		<div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-x-4">
			{#each languages as column}
				<div>
					{#each column as { language, extensions }}
						<div class="mb-2">
							<span class="font-bold">{language}</span>
							<span class="text-gray-400"> ({extensions.join(', ')})</span>
						</div>
					{/each}
				</div>
			{/each}
		</div>
	{/if}

	<h2 id="usage" class="h2 mt-12 mb-2"><a class="underline hover:text-gray-300" href="#usage">Usage</a></h2>

	<p class="mb-6 mt-6">
		To create a paste, go <a class="underline hover:text-gray-300" href="/">home</a> or click the "New" button (<TextPlus
			class="inline-block w-4 h-4"
		/>) in the tool box in the bottom right corner of the page. Paste whatever text you want into
		the editor, and click the "Save" button (<DeviceFloppy class="inline-block w-4 h-4" />) to
		create the paste.
	</p>

	<p class="mb-6 mt-6">
		To copy an existing paste, click the "Copy" button (<Copy class="inline-block w-4 h-4" />)
		in the tool box in the bottom right corner of the page. This will start a new paste with the
		contents of the existing paste.
	</p>

	<h2 id="cli-script" class="h2 mt-12 mb-2"><a class="underline hover:text-gray-300" href="#cli-script">CLI Script</a></h2>

	<p class="mb-6 mt-6">
		To make it easier to create pastes, a CLI script is available. The script can be found <a
		class="underline hover:text-gray-300" href="/paste69.sh">here</a
		>. To use the script:
	</p>

	<pre class="bg-gray-900 py-2 px-4 mb-2 block rounded-lg"><code class="language-bash">curl -O https://0x45.st/paste69.sh && chmod +x paste69.sh
./paste69.sh --help

# Paste69 CLI script
# 
# Usage:
#   paste69 <file> [options]
#   cat <file> | paste69 [options]
# 
# Options:
#   -h, --help                 Show this help text.
#   -l, --language <language>  Set the language of the paste.
#   -p, --password <password>  Set a password for the paste. This enables encryption.
#   -x, --burn                 Burn the paste after it is viewed once.
#   -r, --raw                  Return the raw JSON response.
#   -c, --copy                 Copy the paste URL to the clipboard.</code></pre>

	<p class="mb-6 mt-6">To create a paste with the script, simply pipe the contents of a file to the script:</p>

    <code class="bg-gray-900 py-2 px-4 mb-2 block rounded-lg">cat file.md | ./paste69.sh
# https://0x45.st/some-random-id.md</code>

	<h2 id="api" class="h2 mt-12 mb-2"><a class="underline hover:text-gray-300" href="#api">API</a></h2>

	<p class="mb-6 mt-6">
		Paste69 has a simple API for creating and fetching pastes. The API accepts JSON, form data, and plain text with
		query parameters. The API will respond with JSON or plain text, depenant on the state of the `raw`
		parameter.
	</p>

	<aside class="alert variant-filled-tertiary my-6">
        <!-- Icon -->
        <div><InfoCircleFilled size="42" /></div>
        <!-- Message -->
        <div class="alert-message">
            <h3 class="h3">Note</h3>
            <p>
				The below examples are offered as curl commands to make things simple, but you can use whatever tool you want to
				make requests to the API.
			</p>
        </div>
    </aside>

	<h3 id="api-creating-a-paste" class="h3 mt-8 mb-2">
		<a class="underline hover:text-gray-300" href="#api-creating-a-paste">Creating a Paste</a>
	</h3>

	<p class="mb-6 mt-6">
		To create a paste, send a POST request to <code>/api/pastes</code>. Valid parameters are as follows:
	</p>

	<ul class="list-disc list-inside mb-4">
		<li>
			<code>contents</code> - The contents of the paste.
		</li>
		<li>
			<code>language</code> - The language of the paste. This is used for syntax highlighting. If no language is specified, the
			API will attempt to detect the language.
		</li>
		<li>
			<code>password</code> - A password to encrypt the paste with. This will enable encryption.
		</li>
		<li>
			<code>burnAfterReading</code> - A boolean value to enable burn after reading. If this is set to true, the paste will be deleted
			after it is viewed once.
		</li>
	</ul>

	<h4 class="h4 mt-8 mb-2">Examples</h4>

	<pre class="bg-gray-900 py-4 px-4 mb-2 block rounded-lg whitespace-normal">
		<div class="text-sm font-medium text-gray-500 mb-2">JSON Request</div>
		<code class="whitespace-normal">
			$ curl -X POST -H "Content-Type: application/json" -d '{'{'}"contents": "paste contents"{'}'}' https://0x45.st/api/pastes
		</code>
	</pre>

	<pre class="bg-gray-900 py-4 px-4 mb-2 block rounded-lg  whitespace-normal">
		<div class="text-sm font-medium text-gray-500 mb-2">Form Request</div>
		<code class="whitespace-normal">
			$ curl -X POST -F "contents=paste contents" https://0x45.st/api/pastes<br />
			# or, with a file<br />
			$ curl -X POST -F "contents=@file-name.txt" https://0x45.st/api/pastes
		</code>
	</pre>

	<pre class="bg-gray-900 py-4 px-4 mb-2 block rounded-lg  whitespace-normal">
		<div class="text-sm font-medium text-gray-500 mb-2">Plaintext Request</div>
		<code class="whitespace-normal">
			$ curl -X POST -H "Content-Type: text/plain" -d "paste contents" https://0x45.st/api/pastes
		</code>
	</pre>

	<p class="mb-6 mt-6">If the paste was successfully created, the API will respond with the following JSON:</p>

    <pre class="bg-gray-900 py-2 px-4 mb-2 block rounded-lg"><code class="language-json">{'{'}
	"id": "paste id",
	"url": "https://0x45.st/some-random-id.md",
	"contents": "paste contents",
	"highlight": "txt",
	"encrypted": false,
	"burnAfterReading": false,
	"created_at": "2021-08-05T07:30:00.000Z",
{'}'}</code></pre>

	<h3 id="api-fetching-a-paste" class="h3 mt-4 mb-2">
		<a class="underline hover:text-gray-300" href="#api-fetching-a-paste">Fetching a Paste</a>
	</h3>

	<p class="mb-6 mt-6">
		To fetch a paste, send a GET request to{' '}
		<code>/api/pastes/:id</code>. If the paste exists, the API will respond with the following JSON:
	</p>

    <pre class="bg-gray-900 py-2 px-4 mb-2 block rounded-lg"><code class="language-json">{'{'}
	"id": "paste id",
	"url": "https://0x45.st/some-random-id.md",
	"contents": "paste contents",
	"highlight": "txt",
	"encrypted": false,
	"burnAfterReading": false,
	"created_at": "2021-08-05T07:30:00.000Z",
{'}'}</code></pre>
</div>

<div class="fixed bottom-0 right-0 w-full md:w-auto">
	<ToolBox disableSave={true} disableCopy={true} on:new={() => goto('/')} />
</div>