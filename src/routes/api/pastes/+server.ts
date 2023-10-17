import { detectLanguage } from "$utils/hljs";
import { encrypt as doEncrypt } from "$utils/crypto";
import { error, json, type RequestHandler } from "@sveltejs/kit";
import { generate } from 'random-words';
import { pastes } from "$db/index";
import { env } from "$env/dynamic/private";
import { extensionMap } from "$utils/languages";

export const POST: RequestHandler = async ({ request }) => {
    const { contents, language, encrypt, password, burnAfterReading } = await request.json();
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
    
    if (encrypt && !password) {
        throw error(400, 'No password provided for encryption.');
    } else if (encrypt) {
        pasteContents = await doEncrypt(contents, password);
    }

    const data = {
        id,
        url: `${env.SITE_URL}/${id}.${highlight}`,
        highlight,
        encrypted: !!encrypt,
        contents: pasteContents,
        burnAfterReading: !!burnAfterReading,
        createdAt: new Date(),
    };

    const res = await pastes.insertOne(data);

    if (!res.acknowledged) {
        throw error(500, 'Failed to create paste');
    }

    return json(data, {
        status: 201,
    })
};