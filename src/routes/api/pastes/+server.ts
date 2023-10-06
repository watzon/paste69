import { detectLanguage } from "$utils/hljs";
import { encrypt as doEncrypt } from "$utils/crypto";
import { error, json, type RequestHandler } from "@sveltejs/kit";
import { generate } from 'random-words';
import { pastes } from "$db/index";
import { SITE_URL } from "$env/static/private";

export const POST: RequestHandler = async ({ request }) => {
    const { contents, encrypt, password, burnAfterReading } = await request.json();
    const id = generate({ exactly: 3, join: '-' });

    if (!contents || contents.length === 0) {
        throw error(400, 'No contents provided');
    }

    let pasteContents: string = contents;
    const highlight = detectLanguage(contents) || 'txt';
    
    if (encrypt && !password) {
        throw error(400, 'No password provided for encryption.');
    } else if (encrypt) {
        pasteContents = await doEncrypt(contents, password);
    }

    const data = {
        id,
        url: `${SITE_URL}/${id}.${highlight}`,
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