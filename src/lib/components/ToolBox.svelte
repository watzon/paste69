<script lang="ts">
	import { createEventDispatcher } from 'svelte';
    import { Copy, DeviceFloppy, TextPlus, CaretDown } from 'svelte-tabler';
	import { getModalStore, type ModalComponent, type ModalSettings } from '@skeletonlabs/skeleton';
    import logo from '$lib/assets/logo.svg';
	import Button from './Button.svelte';
	import MoreOptionsForm from './MoreOptionsForm.svelte';

	const modalStore = getModalStore();
    const dispatch = createEventDispatcher();

	let extraOptions = {
		encrypt: false,
		password: undefined as string | undefined,
		burnAfterReading: false,
	};

    export let disableSave: boolean = false;
    export let disableCopy: boolean = false;
	export let disableMoreOptions: boolean = false;

	const modalComponent: ModalComponent = {
		ref: MoreOptionsForm,
	}

	const modalSettings: ModalSettings = {
		type: 'component',
		component: modalComponent,
		response: (data: typeof extraOptions) => {
			extraOptions = data;
			onSave();
		},
	}

    const onSave = () => dispatch('save', extraOptions);
    const onNew = () => dispatch('new');
    const onCopy = () => dispatch('copy');
</script>

<div class="flex flex-row max-w-full md:min-w-[595px] bg-slate-800">
	<a
		href="/about"
		class="flex flex-col items-center justify-center py-2 px-8 bg-black bg-opacity-50"
	>
		<img class="w-8" src={logo} alt="Paste69 Logo" />
	</a>

	<div class="flex flex-col items-center justify-center pt-4 pb-2 px-12 w-full">
		<div class="flex flex-row justify-between gap-2 w-full">
			<Button title="Save" disabled={disableSave} on:click={onSave}>
				<DeviceFloppy />
			</Button>
			<Button title="New" on:click={onNew}>
				<TextPlus />
			</Button>
			<Button title="Copy" disabled={disableCopy} on:click={onCopy}>
				<Copy />
			</Button>
		</div>
		<!-- More options button with horizontal line through the word -->
		<button
			disabled={disableMoreOptions}
			on:click={() => modalStore.trigger(modalSettings)}
			class="w-full text-center text-sm text-gray-300 disabled:text-gray-400 border-b border-gray-500 leading-[0.1em] mt-4 mb-2"
		>
			<span class="bg-slate-800 px-2">More Options</span>
		</button>
	</div>
</div>
