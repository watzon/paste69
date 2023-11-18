import { Mongo } from "$lib/db/index";
import { env } from "$env/dynamic/private";
import { error, type RequestHandler } from "@sveltejs/kit";

const maxLines = 15;

export const GET: RequestHandler = async ({ params }) => {
    const [id, ext] = params.slug.split('.');
    
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
    const highlight = ext || paste.highlight;

    let lines	= code.split('\n').slice(0, maxLines).concat(Array.from({ length: maxLines - code.split('\n').length }, () => ''));
    
    // Truncate each line to 80 characters, and pad the rest with spaces.
    lines		= lines.map(line => line.slice(0, 70).padEnd(70, ' '));

    const title	= `${env.SITE_URL}/${id}.${highlight}`;
    const endpoint	= `https://inkify.0x45.st/generate?code=${encodeURIComponent(lines.join('\n'))}&window_title=${encodeURIComponent(title)}&language=${encodeURIComponent(highlight)}&pad_horiz=5&pad_vert=5`;

    const res = await fetch(endpoint);
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