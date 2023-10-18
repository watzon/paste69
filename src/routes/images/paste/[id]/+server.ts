import { Mongo } from "$lib/db/index";
import { env } from "$env/dynamic/private";
import { error, type RequestHandler } from "@sveltejs/kit";

export const GET: RequestHandler = async ({ params }) => {
    const { id } = params;

    const pastes = await Mongo.getNamedCollection("pastes");
    const paste = await pastes.findOne({ id });

    if (!paste) {
        throw error(404, 'Paste not found');
    }

    if (paste.encrypted) {
        throw error(404, 'Cannot generate image for encrypted paste');
    }

    if (paste.burnAfterReading) {
        throw error(404, 'Cannot generate image for burnable paste');
    }

    const code = paste.contents;

    // Grab at most 15 lines of the paste, if there aren't 15 lines, pad the rest with empty strings.
    let lines	= code.split('\n').slice(0, 15).concat(Array.from({ length: 15 - code.split('\n').length }, () => ''));
    
    // Truncate each line to 80 characters, and pad the rest with spaces.
    lines		= lines.map(line => line.slice(0, 70).padEnd(70, ' '));

    const title	= `${env.SITE_URL}/${id}.${paste.highlight}`;
    const url	= `https://inkify.0x45.st/generate?code=${encodeURIComponent(lines.join('\n'))}&window_title=${encodeURIComponent(title)}&language=${encodeURIComponent(paste.highlight)}&pad_horiz=5&pad_vert=5`;

    const res = await fetch(url);
    const image = res.body;

    if (image) {
        return new Response(image, {
            headers: {
                'Content-Type': 'image/png',
                'Cache-Control': 'public, max-age=604800, immutable',
            },
        });
    } else {
        throw error(500, 'Could not generate image');
    }
};