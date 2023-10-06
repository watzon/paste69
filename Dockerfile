# Build the svelte kit project
FROM node:20.7.0-alpine as build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --silent

COPY . ./

# Pass through the necessary environment variables
ENV SITE_URL=${SITE_URL}
ENV DB_URL=${DB_URL}
ENV SENTRY_DSN=${SENTRY_DSN}
ENV PUBLIC_GOOGLE_ANALYTICS_SITE_ID=${PUBLIC_GOOGLE_ANALYTICS_SITE_ID}
ENV PUBLIC_PLAUSIBLE_URL=${PUBLIC_PLAUSIBLE_URL}
ENV PUBLIC_PLAUSIBLE_DOMAIN=${PUBLIC_PLAUSIBLE_DOMAIN}
ENV PUBLIC_ACKEE_URL=${PUBLIC_ACKEE_URL}
ENV PUBLIC_ACKEE_DOMAIN_ID=${PUBLIC_ACKEE_DOMAIN_ID}
ENV PUBLIC_MATOMO_URL=${PUBLIC_MATOMO_URL}
ENV PUBLIC_MATOMO_SITE_ID=${PUBLIC_MATOMO_SITE_ID}

RUN npm run build

# Serve the built project
FROM node:20.7.0-alpine as serve

WORKDIR /app

COPY --from=build /app/build .
COPY --from=build /app/package.json .
COPY --from=build /app/node_modules ./node_modules

CMD ["node", "index.js"]
