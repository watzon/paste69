<script lang="ts">
	import type { PageData } from './$types';
	import ToolBox from '$lib/components/ToolBox.svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { highlight } from '$utils/hljs';
	import { markdown } from '$utils/markdown';
	import { getModalStore, getToastStore, type ModalSettings } from '@skeletonlabs/skeleton';
	import { sleep } from '$utils/index';

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
		(data.highlight === 'md' ||
		data.highlight === 'markdown') &&
			(($page.url.searchParams.has('render') && !$page.url.searchParams.get('render')) ||
				$page.url.searchParams.get('render') === 'true');

	if (data.encrypted && !decryptedData) {
		let modalOptions: ModalSettings;

		const onResponse = async (password?: string) => {
			if (!password || password.length === 0) {
				await sleep(500);
				return modalStore.trigger(modalOptions)
			};

			// Use the /api/pastes/[id]/decrypt endpoint to decrypt the paste
			// and set the decryptedData variable to the result.
			const result = await fetch(`/api/pastes/${data.id}/decrypt`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ password }),
			});

			if (result.ok) {
				const { contents: decrypted } = await result.json();
				decryptedData = decrypted;
			} else {
				modalStore.trigger(modalOptions);
				await sleep(500);
				const id = toastStore.trigger({
					message: 'Failed to decrypt paste.',
					background: 'variant-filled-error',
				});
			}
		};

		modalOptions = {
			type: 'prompt',
			title: 'Encrypted Paste',
			body: 'Enter the password to decrypt the paste.',
			valueAttr: { type: 'password', required: 'true', placeholder: 'Password', class: 'modal-prompt-input input px-4 py-2' },
			response: onResponse,
		};

		modalStore.trigger(modalOptions);
	}

	$: contents = renderMarkdown ? markdown(decryptedData ?? data.contents) : highlight(decryptedData ?? data.contents, data.highlight);
</script>

<svelte:head>
    <title>Paste69 - Paste {data.id}</title>
</svelte:head>

{#if renderMarkdown}
	<!-- prettier-ignore -->
    <div class="markdown text-xl max-w-[90ch] pb-24">{@html contents}</div>
{:else}
    <pre class="pt-5 pb-24 w-full whitespace-pre-wrap" bind:this={codeRef} on:dblclick={() => selectAll()} ><code>{@html contents}</code></pre>
{/if}

<div class="fixed bottom-0 right-0 w-full md:w-auto">
	<ToolBox
		disableSave={true}
		disableMoreOptions={true}
		disableCopy={data.encrypted}
		on:new={() => goto('/')}
		on:copy={() => goto(`/?copy-from=${data.id}`)}
	/>
</div>
