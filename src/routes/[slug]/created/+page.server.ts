import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { pastes } from '$db/index';
import { SITE_URL } from '$env/static/private';

export const load: PageLoad = async ({ params }) => {
    const paste = await pastes.findOne({ id: params.slug });

    if (!paste) {
        throw error(404, 'Paste not found');
    }

    const pasteUrl = `${SITE_URL}/${paste.id}.${paste.highlight}`;

    return {
        pasteUrl,
    };
};