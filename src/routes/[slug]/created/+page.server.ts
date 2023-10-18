import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { Mongo } from '$lib/db/index';
import { env } from '$env/dynamic/private';

export const load: PageLoad = async ({ params }) => {
    const pastes = await Mongo.getNamedCollection('pastes');
    const paste = await pastes.findOne({ id: params.slug });

    if (!paste) {
        throw error(404, 'Paste not found');
    }

    const pasteUrl = `${env.SITE_URL}/${paste.id}.${paste.highlight}`;

    return {
        pasteUrl,
    };
};