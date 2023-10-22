import { detectLanguage } from "$utils/hljs";
import { encrypt as doEncrypt } from "$utils/crypto";
import { error, json, text, type RequestHandler } from "@sveltejs/kit";
import { generate } from 'random-words';
import { Mongo } from "$lib/db/index";
import { env } from "$env/dynamic/private";
import { extensionMap } from "$utils/languages";

interface PasteOptions {
    contents?: string;
    language?: string;
    encrypt?: boolean;
    password?: string;
    burnAfterReading?: boolean;
    raw?: boolean;
}

const isTrue = (value: string | boolean | undefined): boolean => {
    if (typeof value === 'boolean') {
        return value;
    } else if (typeof value === 'string') {
        return ['true', '1', 'yes', 'y', 'on'].includes(value.toLowerCase());
    } else {
        return false;
    }
}

// Extract the options from the form data.
const extractOptionsFromForm = async (req: Request): Promise<PasteOptions> => {
    const form = await req.formData();
    const contents = form.get('contents');
    const language = form.get('language') as string;
    const password = form.get('password') as string;
    const burnAfterReading = form.get('burnAfterReading') as string;
    const raw = form.get('raw') as string;

    let text: string;
    // Check if contents is a file, if so read it.
    if (contents instanceof File) {
        text = await contents.text();
    } else {
        text = contents as string;
    }

    if (!text || text.length === 0) {
        throw error(400, 'No contents provided for your paste.')
    }

    return {
        contents: text,
        language,
        password,
        burnAfterReading: isTrue(burnAfterReading),
        raw: isTrue(raw),
    };
};

// Extract the options from the JSON body.
const extractOptionsFromJSON = async (req: Request): Promise<PasteOptions> => {
    const { contents, language, password, burnAfterReading, raw } = await req.json();

    if (!contents || contents.length === 0) {
        throw error(400, 'No contents provided for your paste.')
    }

    return {
        contents,
        language,
        password,
        burnAfterReading: isTrue(burnAfterReading),
        raw: isTrue(raw),
    };
};

// Extract the options from the query string, and body.
const extractOptionsFromQuery = async (req: Request): Promise<PasteOptions> => {
    const url = new URL(req.url);
    const query = url.searchParams;
    
    const contents = await req.text();

    if (!contents) {
        throw error(400, 'No contents provided for your paste.')
    }
    
    const language = query.get('language') as string;
    const password = query.get('password') as string;
    const burnAfterReading = query.get('burnAfterReading') as string;
    const raw = query.get('raw') as string;

    return {
        contents,
        language,
        password,
        burnAfterReading: isTrue(burnAfterReading),
        raw: isTrue(raw),
    };
};

// Extract the options from the request, depending on the content type.
const extractOptions = async (req: Request): Promise<PasteOptions> => {
    const contentType = req.headers.get('content-type') || '';
    if (contentType.includes('form')) {
        return await extractOptionsFromForm(req);
    } else if (contentType.includes('json')) {
        return await extractOptionsFromJSON(req);
    } else {
        return await extractOptionsFromQuery(req);
    }
};

export const POST: RequestHandler = async ({ request }) => {
    const { contents, language, password, burnAfterReading, raw } = await extractOptions(request);
    const id = generate({ exactly: 3, join: '-' });

    if (!contents || contents.length === 0) {
        throw error(400, 'No contents provided');
    }

    if (language && language.length > 0) {
        // Check the language names, as well as the extensions for each language.
        // Try to make it as efficient as possible.
        const lang = language.toLowerCase();
        const languages = Object.keys(extensionMap);
        const extensions = Object.values(extensionMap).flat();
        if (!languages.includes(lang) && !extensions.includes(lang)) {
            throw error(400, 'Invalid language');
        }
    }

    let pasteContents: string = contents;
    const highlight = language || detectLanguage(contents) || 'txt';
    
    if (password) {
        pasteContents = await doEncrypt(contents, password);
    }

    const data = {
        id,
        highlight,
        encrypted: !!password,
        contents: pasteContents,
        burnAfterReading: !!burnAfterReading,
        createdAt: new Date(),
    };

    const pastes = await Mongo.getNamedCollection("pastes");
    const res = await pastes.insertOne(data);

    const url = `${env.SITE_URL}/${id}.${highlight}`;

    if (!res.acknowledged) {
        throw error(500, 'Failed to create paste');
    }

    if (raw) {
        return json({
            ...data,
            url,
        }, {
            status: 201,
        });
    } else {
        return text(url + '\n');
    }
};