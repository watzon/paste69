<script>
	import '../app.postcss';
	import { env } from "$env/dynamic/public";
	import { Modal, Toast, initializeStores } from '@skeletonlabs/skeleton';

	initializeStores();

	const umami_url = env.PUBLIC_UMAMI_URL;
	const umami_site_id = env.PUBLIC_UMAMI_SITE_ID;
</script>

<svelte:head>
	{#if umami_url && umami_site_id}
		<script async src="{umami_url}/script.js" data-website-id={umami_site_id}></script>
	{/if}
</svelte:head>

<Modal />
<Toast />
<slot />
