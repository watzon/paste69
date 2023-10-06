import { pastes } from "$db/index";
import { error, json, type RequestHandler } from "@sveltejs/kit";

// Fetch the paste with the given ID, returning it as a JSON object.
export const GET: RequestHandler = async ({ params }) => {
    const { id } = params;

    const paste = await pastes.findOne({ id });

    if (!paste) {
        throw error(404, 'Paste not found');
    }

    if (paste.encrypted) {
        throw error(400, 'Paste is encrypted');
    }

    if (paste.burnAfterReading) {
        await pastes.deleteOne({ id });
    }

    const data = {
        id: paste.id,
        highlight: paste.highlight,
        contents: paste.contents,
        burnAfterReading: paste.burnAfterReading,
        createdAt: paste.createdAt,
    }

    return json(data);
};