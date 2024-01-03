FROM crystallang/crystal:latest

WORKDIR /app

RUN apt-get update && apt-get install libmagic-dev -y

COPY . .

RUN shards install
RUN shards build --release

ENTRYPOINT [ "docker/entrypoint.sh" ]