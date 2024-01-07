FROM crystallang/crystal:latest

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    libmagic-dev \
    libsqlite3-dev

COPY . .

RUN shards install
RUN shards build server --release
RUN shards build cli

RUN chmod +x ./docker/entrypoint.sh

ENTRYPOINT [ "docker/entrypoint.sh" ]