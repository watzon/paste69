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
    class="pl-12 pt-5 w-full h-full bg-transparent border-none resize-none outline-none font-monaspaceNeon text-lg"
    bind:value={contents}
    bind:this={ref}
    {...$$restProps}
/>