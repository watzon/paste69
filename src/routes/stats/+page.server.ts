import { Mongo } from "$lib/db/index";
import type { PageServerLoad } from "./$types";
import { env } from '$env/dynamic/private';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async () => {
    // Check if the stats page is enabled
    if (!env.STATS_ENABLED) {
        throw error(404, 'Paste not found');
    }

    const pastes = await Mongo.getNamedCollection('pastes');
    
    // Total pastes
    const totalPastes = await pastes.countDocuments();
    
    // Total encrypted pastes
    const totalEncryptedPastes = await pastes.countDocuments({ encrypted: true });

    // Total pastes with burnAfterReading enabled (and not yet read)
    const totalBurnAfterReadingPastes = await pastes.countDocuments({ burnAfterReading: true });

    return {
        totalPastes,
        totalEncryptedPastes,
        totalBurnAfterReadingPastes,
    };
}