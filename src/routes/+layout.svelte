<script>
	import '../app.postcss';
	import { Modal, Toast, initializeStores } from '@skeletonlabs/skeleton';

	initializeStores();
</script>

<svelte:head>
	<script async src="https://analytics.watzon.tech/script.js" data-website-id="542d82bc-7f24-4b96-bc79-b73f2e5f955f"></script>
</svelte:head>

<Modal />
<Toast />
<slot />
