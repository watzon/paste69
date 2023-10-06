import { pastes } from "$db/index";
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ url }) => {
    // Check if the `copyFrom` query parameter is present
    const copyFrom = url.searchParams.get("copy-from");
    if (copyFrom) {
        // If it is, we need to fetch the paste from the database
        // and return it to the client.
        const paste = await pastes.findOne({ id: copyFrom });
        return {
            paste: structuredClone(paste),
        }
    }
}