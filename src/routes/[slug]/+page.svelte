<script lang="ts">
	import type { PageData } from './$types';
	import ToolBox from '$lib/components/ToolBox.svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { highlight } from '$utils/hljs';
	import { markdown } from '$utils/markdown';
	import { getModalStore, getToastStore, type ModalSettings } from '@skeletonlabs/skeleton';
	import { sleep } from '$utils/index';
	import { ChevronLeft, ChevronRight } from 'svelte-tabler';
	import ShareMenu from '$lib/components/ShareMenu.svelte';

	let codeRef: HTMLPreElement;

	const modalStore = getModalStore();
	const toastStore = getToastStore();

	export let data: PageData;
	let decryptedData: string | undefined = undefined;

	// Select all the text in the code block when it is double clicked.
	const selectAll = () => {
		const selection = window.getSelection();
		const range = document.createRange();
		range.selectNodeContents(codeRef);
		selection?.removeAllRanges();
		selection?.addRange(range);
	};

	// If the highlight is set to 'md' or 'markdown', and the
	// query contains either 'render' or 'render=true'
	// then we will render the markdown.
	const renderMarkdown =
		(data.highlight === 'md' || data.highlight === 'markdown') &&
		(($page.url.searchParams.has('render') && !$page.url.searchParams.get('render')) ||
			$page.url.searchParams.get('render') === 'true');

	if (data.encrypted && !decryptedData) {
		let modalOptions: ModalSettings;

		const onResponse = async (password?: string) => {
			if (!password || password.length === 0) {
				await sleep(500);
				return modalStore.trigger(modalOptions);
			}

			// Use the /api/pastes/[id]/decrypt endpoint to decrypt the paste
			// and set the decryptedData variable to the result.
			const result = await fetch(`/api/pastes/${data.id}/decrypt`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ password })
			});

			if (result.ok) {
				const { contents: decrypted } = await result.json();
				decryptedData = decrypted;
			} else {
				modalStore.trigger(modalOptions);
				await sleep(500);
				const id = toastStore.trigger({
					message: 'Failed to decrypt paste.',
					background: 'variant-filled-error'
				});
			}
		};

		modalOptions = {
			type: 'prompt',
			title: 'Encrypted Paste',
			body: 'Enter the password to decrypt the paste.',
			valueAttr: {
				type: 'password',
				required: 'true',
				placeholder: 'Password',
				class: 'modal-prompt-input input px-4 py-2'
			},
			response: onResponse
		};

		modalStore.trigger(modalOptions);
	}

	let shareMenuOpen = false;

	const toggleShareMenu = () => {
		shareMenuOpen = !shareMenuOpen;
	};

	const copyContents = () => {
		navigator.clipboard.writeText(decryptedData ?? data.contents);
		toastStore.trigger({
			message: 'Copied paste contents to clipboard.',
			background: 'variant-filled-success'
		});
	};

	$: contents = renderMarkdown
		? markdown(decryptedData ?? data.contents)
		: highlight(decryptedData ?? data.contents, data.highlight);
</script>

<svelte:head>
	<title>Paste69 - Paste {data.id}</title>
	<meta name="description" content="Paste69 - Paste {data.id}" />
	<meta property="og:title" content="Paste69 - Paste {data.id}" />
	<meta property="og:description" content="Paste69 - Paste {data.id}" />
	<meta property="og:image" content={data.ogImageUrl} />
	<meta property="og:url" content={data.pasteUrl} />
	<meta property="og:type" content="website" />
</svelte:head>

{#if renderMarkdown}
	<!-- prettier-ignore -->
	<div class="markdown text-xl max-w-[90ch] pl-12 pt-4 pb-24">{@html contents}</div>
	<div class="absolute top-[23px] left-[5px]">
		<ChevronRight />
	</div>
{:else}
	<pre
		class="pl-2 pt-4 pb-24 min-h-full max-w-full break-words whitespace-pre-line overflow-x-auto"
		bind:this={codeRef}
		on:dblclick={() => selectAll()}><code>{@html contents}</code></pre>
{/if}

<div
	class="fixed right-0 top-1/2 -translate-y-1/2 transition-all {shareMenuOpen ||
		'translate-x-[80px]'}"
>
	<button on:click={toggleShareMenu} class="px-0.5 py-2 bg-slate-800 absolute top-1/2 -translate-y-1/2 -translate-x-full grid grid-flow-col auto-cols-min items-center justify-center">
		{#if shareMenuOpen}
			<ChevronRight size="18"/>
		{:else}
			<ChevronLeft size="18"/>
		{/if}
		<div class="text-gray-400 tracking-widest" style="writing-mode: vertical-rl;">SHARE</div>
	</button>
	<ShareMenu pasteUrl={data.pasteUrl} on:copy={copyContents} />
</div>

<div class="fixed bottom-0 right-0 w-full md:w-auto">
	<ToolBox
		disableSave={true}
		disableMoreOptions={true}
		disableCopy={data.encrypted}
		on:new={() => goto('/')}
		on:copy={() => goto(`/?copy-from=${data.id}`)}
	/>
</div>
