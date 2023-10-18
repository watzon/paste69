import { writable } from 'svelte/store';
import type PasteSchema from '$lib/db/paste-schema';

export const paste = writable<PasteSchema>({
    id: '',
    contents: '',
    highlight: '',
    createdAt: new Date(),
});