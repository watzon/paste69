<script lang="ts">
    import { SlideToggle } from '@skeletonlabs/skeleton';

	/** Exposes parent props to this component. */
	export let parent: any;

	import { getModalStore } from '@skeletonlabs/skeleton';
	const modalStore = getModalStore();

	// Form Data
	const formData = {
        encrypt: false,
        password: undefined,
        burnAfterReading: false,
	};

	// Custom submit function to pass the response and close the modal.
	function onFormSubmit(): void {
		if ($modalStore[0].response) $modalStore[0].response(formData);
		modalStore.close();
	}

	// Base Classes
	const cBase = 'card p-4 w-modal shadow-xl space-y-4';
	const cHeader = 'text-2xl font-bold';
	const cForm = 'border border-surface-500 p-4 space-y-4 rounded-container-token';
</script>

{#if $modalStore[0]}
	<div class="modal-example-form {cBase}">
		<header class={cHeader}>Options for Saving</header>
		<article>Some extra options for saving. Encrypting your paste will make it require a password for anyone to open it. Burn after reading makes your paste viewable only once.</article>
		<form class="modal-form {cForm}">
            <div class="grid grid-cols-3">
                <div class="col-span-1">Encrypt</div>
                <SlideToggle name="slide" bind:checked={formData.encrypt} />
            </div>
            {#if formData.encrypt}
			<div class="grid grid-cols-3">
				<div class="col-span-1">Password</div>
				<input class="input col-span-2 px-2 py-1" type="password" bind:value={formData.password} placeholder="Encryption password..." />
			</div>
            {/if}
            <div class="grid grid-cols-3">
                <div class="col-span-1">Burn After Reading</div>
                <SlideToggle name="slide" bind:checked={formData.burnAfterReading} />
            </div>
		</form>
		<!-- prettier-ignore -->
		<footer class="modal-footer {parent.regionFooter}">
        <button class="btn {parent.buttonNeutral}" on:click={parent.onClose}>{parent.buttonTextCancel}</button>
        <button class="btn {parent.buttonPositive}" on:click={onFormSubmit}>Save Paste</button>
    </footer>
	</div>
{/if}