import { SENTRY_DSN } from '$env/static/private';
import * as Sentry from '@sentry/node';
import type { HandleServerError } from '@sveltejs/kit';

Sentry.init({
	dsn: SENTRY_DSN,
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