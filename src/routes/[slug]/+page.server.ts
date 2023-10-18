import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { Mongo } from '$lib/db/index';
import { env } from '$env/dynamic/private';

export const load: PageLoad = async ({ params }) => {
    const [id, ext] = params.slug.split('.');
    
    // Fetch the paste
    const pastes = await Mongo.getNamedCollection('pastes');
    const paste = await pastes.findOne({ id });
    if (!paste) {
        throw error(404, 'Paste not found');
    }

    // Build the response object
    const response = {
        id: paste.id,
        url: `${env.SITE_URL}/${id}.${paste.highlight}`,
        contents: paste.contents,
        encrypted: paste.encrypted,
        highlight: ext || paste.highlight,
        burnAfterReading: paste.burnAfterReading,
    }

    // If the paste is set as burnAfterReading, delete it
    if (paste.burnAfterReading) {
        await pastes.deleteOne({ id });
    }

    return response;
};