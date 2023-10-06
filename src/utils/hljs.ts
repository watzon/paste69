import hljs from 'highlight.js';
import { extensionMap, languages } from './languages';

// Theme
import 'highlight.js/styles/github-dark.css';

const autoLanguages = ['js', 'ts', 'css', 'html', 'json', 'md', 'php', 'py', 'rb', 'rs', 'shell'];

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

// Re-export the `hljs` object
export default hljs;