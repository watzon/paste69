# Build the svelte kit project
FROM node:20.7.0-alpine as build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --silent

COPY . ./

RUN npm run build

# Serve the built project
FROM node:20.7.0-alpine as serve

WORKDIR /app

COPY --from=build /app/build .
COPY --from=build /app/package.json .
COPY --from=build /app/node_modules ./node_modules

CMD ["node", "index.js"]
