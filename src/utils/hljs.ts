import hljs from 'highlight.js';
import { extensionMap, languages } from './languages';

// Theme
import 'highlight.js/styles/github-dark.css';

const autoLanguages = ['js', 'ts', 'css', 'go', 'html', 'json', 'md', 'php', 'py', 'rb', 'rs', 'bash'];

for (const [lang, exts] of Object.entries(extensionMap)) {
	if (exts.length > 0) {
		// Remove leading underscore, replace other underscores with dashes
		const name = lang.replace(/^_/, '').replace(/_/g, '-');
		// @ts-expect-error: this is valid
		hljs.registerLanguage(name, languages[lang]!);
		hljs.registerAliases(exts, { languageName: lang });
	}
}

export const detectLanguage = (code: string) => {
	return hljs.highlightAuto(code, autoLanguages).language;
};

export const highlight = (code: string, lang: string | undefined = undefined) => {
	if (!lang) {
		return hljs.highlightAuto(code, autoLanguages).value;
	} else {
		return hljs.highlight(code, { language: lang }).value;
	}
};


hljs.addPlugin({
	'after:highlight': (result) => {
		const code = result.value.split('\n').map((line, index) => {
			const lineNumber = index + 1;
			const paddedLineNumber = String(lineNumber).padStart(5, ' ');

			return `<div class="flex flex-row items-start justify-start gap-8"><div class="text-gray-400 select-none shrink-0 min-w-14">${paddedLineNumber}</div><pre class="whitespace-pre-wrap">${line}</pre></div>`;
		}).join('\n');

		result.value = `<div class="flex flex-col">${code}</div>`
	},
});

// Re-export the `hljs` object
export default hljs;