# Build the svelte kit project
FROM node:20.7.0-alpine as build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build
RUN npm ci --prod

# Serve the built project
FROM node:20.7.0-alpine as serve

USER node:node

WORKDIR /app

COPY --from=build --chown=node:node /app/build ./build
COPY --from=build --chown=node:node /app/node_modules ./node_modules

COPY --chown=node:node package.json .

ENTRYPOINT ["node", "build/index.js"]
