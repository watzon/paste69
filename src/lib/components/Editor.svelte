<script lang="ts">
    import { onMount } from 'svelte';
	import type { HTMLTextareaAttributes } from 'svelte/elements';

    export let contents = '';
    let ref: HTMLTextAreaElement;

    interface $$Props extends HTMLTextareaAttributes {
        contents: string;
    }

    onMount(() => {
        ref.focus();
    });
</script>

<textarea
    class="w-full h-full bg-transparent border-none resize-none outline-none"
    bind:value={contents}
    bind:this={ref}
    {...$$restProps}
/>