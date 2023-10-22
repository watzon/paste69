<script lang="ts">
    import type { PageData } from './$types';
    import { ChevronRight } from 'svelte-tabler';
    import Editor from '$lib/components/Editor.svelte';
	import ToolBox from '$lib/components/ToolBox.svelte';
	import { goto } from '$app/navigation';
	import { getToastStore } from '@skeletonlabs/skeleton';
	import { paste } from '../stores/app';

    const toastStore = getToastStore();
    
    export let data: PageData;
    let contents = data.paste?.contents ?? '';

    const newPaste = () => {
        contents = '';
        goto('/');
    };

    const savePaste = async (event: any) => {
        const res = await fetch('/api/pastes', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                contents,
                raw: true,
                ...event.detail,
            })
        });

        if (res.ok) {
            const { id, highlight, burnAfterReading } = await res.json();
            if (burnAfterReading) {
                goto(`/${id}/created`);
            } else {
                goto(`/${id}.${highlight}`);
            }
        } else {
            toastStore.trigger({
                message: 'Failed to save paste.',
                background: 'variant-filled-error',
                autohide: false,
            })
        }
    };
</script>

<svelte:head>
    <title>Paste69 - Paste, if you dare</title>
</svelte:head>

<div class="absolute top-[23px] left-[5px]">
    <ChevronRight />
</div>

<Editor
    placeholder="Paste something, type something, do something."
    bind:contents={contents}
/>

<div class="fixed bottom-0 right-0 w-full md:w-auto">
    <ToolBox
        disableSave={!contents}
        disableCopy={true}
        on:save={savePaste}
        on:new={newPaste}
    />
</div>