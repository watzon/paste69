<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import ToolBox from '$lib/components/ToolBox.svelte';
	import { ChevronRight } from 'svelte-tabler';

	console.log($page);
</script>

<svelte:head>
    <title>Paste69 - {$page.status} error</title>
</svelte:head>

<div class="absolute top-[23px] left-[5px]">
    <ChevronRight />
</div>

<div class="flex flex-row items-center justify-center h-screen">
	<div class="text-xl text-center">
		<h1 class="h1 mb-2 p-0">{$page.status}</h1>
		<p class="mb-2">{$page.error?.message}</p>
	</div>
</div>

<div class="fixed bottom-0 right-0 w-full md:w-auto">
	<ToolBox
		disableSave={true}
		disableCopy={true}
		disableMoreOptions={true}
		on:new={() => goto('/')}
	/>
</div>
