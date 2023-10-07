import { error, json, type RequestHandler } from "@sveltejs/kit";
import { pastes } from "$db/index";
import { decrypt } from "$utils/crypto";

// Decrypt the paste with the given ID using the provided password.
export const POST: RequestHandler = async ({ params, request }) => {
    const { id } = params;
    const { password } = await request.json();

    const paste = await pastes.findOne({ id });

    if (!paste) {
        throw error(404, 'Paste not found');
    }

    if (!paste.encrypted) {
        throw error(400, 'Paste is not encrypted');
    }

    if (!password) {
        throw error(400, 'No password provided for decryption.');
    }

    try {
        const contents = await decrypt(paste.contents, password);

        return json({
            ...paste,
            contents,
        });
    } catch {
        throw error(400, 'Invalid password');
    }
};