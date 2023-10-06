<script lang="ts">
    import type { PageData } from './$types';
	import { goto } from "$app/navigation";
	import ToolBox from "$lib/components/ToolBox.svelte";
	import { ChevronRight } from "svelte-tabler";

    export let data: PageData;
</script>

<svelte:head>
    <title>Paste69 - Burnable paste created</title>
</svelte:head>

<div class="absolute top-[18px] left-[5px]">
	<ChevronRight />
</div>
<div class="fixed bottom-0 right-0">
	<ToolBox
        disableSave={true}
        disableCopy={true}
        disableMoreOptions={true}
        on:new={() => goto('/')}
    />
</div>
<div class="flex flex-col w-full h-full justify-center items-center">
	<div class="text-center text-xl">
		<h1 class="h1 mb-6 text-center">Your burnable paste has been created.</h1>
		<p class="mb-2">Share the following link with someone, and once they view it, it will be deleted forever.</p>
		<a class="text-2xl underline" href={data.pasteUrl}>{data.pasteUrl}</a>
	</div>
</div>
