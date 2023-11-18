
import { join } from 'path';
import type { Config } from 'tailwindcss';

import forms from '@tailwindcss/forms';
import { skeleton } from '@skeletonlabs/tw-plugin';

const config = {
	darkMode: 'class',
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		join(require.resolve(
			'@skeletonlabs/skeleton'),
			'../**/*.{html,js,svelte,ts}'
		)
	],
	theme: {
		extend: {
			fontFamily: {
				monaspaceNeon: ['Monaspace Neon'],
			},
		},
	},
	plugins: [
		forms,
		skeleton({
			themes: {
				preset: ['skeleton'],
			},
		}),
	],
	safelist: [
		'mb-8',
	]
} satisfies Config;

export default config;