<script lang="ts">
    import type { PageData } from './$types';
    import { goto } from '$app/navigation';
	import ToolBox from "$lib/components/ToolBox.svelte";
	import { ChevronRight } from "svelte-tabler";

    export let data: PageData;
    const { totalPastes, totalEncryptedPastes, totalBurnAfterReadingPastes, averagePasteSize } = data;
</script>

<svelte:head>
    <title>Paste69 - Server stats</title>
</svelte:head>

<div class="absolute top-[23px] left-[5px]">
    <ChevronRight />
</div>

<div class="pl-12 pt-4 pb-24 max-w-[100ch]">
	<h1 class="h1 mb-8">Server Stats</h1>
    
    <p class="mb-4">
        <span class="font-bold">Total pastes:</span> {totalPastes}
    </p>

    <p class="mb-4">
        <span class="font-bold">Total encrypted pastes:</span> {totalEncryptedPastes}
    </p>

    <p class="mb-4">
        <span class="font-bold">Total burn after reading pastes (unread):</span> {totalBurnAfterReadingPastes}
    </p>

    <p class="mb-4">
        <span class="font-bold">Average paste size:</span> {averagePasteSize} bytes
    </p>
</div>

<div class="fixed bottom-0 right-0 w-full md:w-auto">
    <ToolBox
        disableSave={true}
        disableCopy={true}
        on:new={() => goto('/')}
    />
</div>