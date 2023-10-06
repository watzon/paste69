<script lang="ts">
	import type { HTMLButtonAttributes } from "svelte/elements";

    interface $$Props extends HTMLButtonAttributes {}
</script>

<button
    {...$$restProps}
    on:click
    class="px-2 py-2 text-gray-100 border border-gray-300 bg-teal-500 hover:bg-teal-800 disabled:bg-gray-700 bg-opacity-30 transition-colors"
>
    <slot />
</button>