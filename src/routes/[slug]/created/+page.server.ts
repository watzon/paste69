import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { pastes } from '$db/index';
import { env } from '$env/dynamic/private';

export const load: PageLoad = async ({ params }) => {
    const paste = await pastes.findOne({ id: params.slug });

    if (!paste) {
        throw error(404, 'Paste not found');
    }

    const pasteUrl = `${env.SITE_URL}/${paste.id}.${paste.highlight}`;

    return {
        pasteUrl,
    };
};