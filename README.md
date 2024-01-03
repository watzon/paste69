# Paste69

This project has undergone several changes, but here's where we are now:
Paste69 is a clone of the popular pastebin service 0x45.st, but written in Crystal using [the Athena framework](https://athenaframework.org/) rather than in Python with Flask.

## Installation

Installation requires [Crystal](https://crystal-lang.org/) and Postgres. Other databases might be supported in the future.

Clone this repo:
```bash
git clone https://github.com/watzon/paste69
```

Install dependencies:
```bash
shards install
```

Copy and modify the config file:
```bash
cp config/config.example.yml config/config.yml
vim config/config.yml
```

Build the executables, migrate the database, and run the server:
```bash
shards build
./bin/cli db:migrate # this assumes the dabase exists, if not run db:create first
./bin/server
```

## Development

Feel free to make pull requests!

## Contributing

1. Fork it (<https://github.com/watzon/paste69/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris W](https://github.com/watzon) - creator and maintainer
