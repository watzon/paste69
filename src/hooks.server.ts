import { env } from '$env/dynamic/private';
import { Mongo } from '$lib/db/index';
import * as Sentry from '@sentry/node';
import type { Handle, HandleServerError } from '@sveltejs/kit';

Sentry.init({
    dsn: env.SENTRY_DSN,
});

interface ServerError extends Error {
    code?: string;
}

export const handleError: HandleServerError = ({ error, event }) => {
    Sentry.captureException(error, { extra: { event } });

    return {
        message: 'Uh oh! An unexpected error occurred.',
        code: (error as ServerError)?.code ?? '500',
    };
};