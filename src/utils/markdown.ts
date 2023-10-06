import { CodeBlock } from '@skeletonlabs/skeleton';
import { Marked, Renderer } from '@ts-stack/markdown';
import { highlight } from './hljs';
import { getLanguageName } from './languages';

class PasteRenderer extends Renderer {
    override heading(text: string, level: number) {
        const margin = level === 1 ? 8 : 2;
        return `<h${level} class="h${level} mb-${margin} font-bold">${text}</h${level}>`;
    }

    override paragraph(text: string): string {
        return `<p class="mt-0 mb-5">${text}</p>`;
    }

    override link(href: string, title: string, text: string): string {
        return `<a href="${href}" title="${title}" target="_blank" rel="noopener noreferrer" class="underline">${text}</a>`;
    }

    override list(body: string, ordered?: boolean | undefined): string {
        const tag = ordered ? 'ol' : 'ul';
        return `<${tag} class="list-disc mt-5 mb-5 pl-7">${body}</${tag}>`;
    }

    override code(code: string, lang?: string | undefined): string {
        const highlighted = highlight(code, lang);
        const languageName = lang ? getLanguageName(lang) : '';
        return `<div class="codeblock overflow-hidden shadow bg-neutral-900/90  text-sm text-white rounded-container-token" data-testid="codeblock">
    <header class="codeblock-header text-xs text-white/50 uppercase flex justify-between items-center p-2 pl-4">
        <span class="codeblock-language">${languageName}</span>
    </header>
    <pre class="codeblock-pre whitespace-pre-wrap break-all p-4 pt-1"><code class="codeblock-code language-bash lineNumbers">${highlighted}</code></pre>
</div>`
    }
}

Marked.setOptions({
    gfm: true,
    tables: true,
    breaks: false,
    pedantic: false,
    sanitize: true,
    smartLists: true,
    smartypants: false,
    renderer: new PasteRenderer(),
});

export function markdown(text: string) {
    return Marked.parse(text);
}
