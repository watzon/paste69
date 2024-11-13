# Paste69

> [!WARNING]  
> Please see [0x45](https://github.com/watzon/0x45) for the successor to this project.

This project has undergone several changes, but here's where we are now:
Paste69 is a clone of the popular pastebin service 0x45.st, but written in Crystal using [the Athena framework](https://athenaframework.org/) rather than in Python with Flask.

## Differences from 0x0

I have tried to keep feature parody with 0x0, but there are some small differences:

- Multiple storage providers are supported (local and s3 for now)
- The configuration format is slightly different, as are some config items

Some features have also yet to be implemented. They will be coming in the near future. These features include:

- NSFW detection
- Virus scanning

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

### Using Docker

If you want, you can build the Docker container yourself locally:

```bash
docker build -v ./uploads:/app/uploads --tag paste69 ./docker
docker run -d -p 8080:8080 paste69
```

Or, you can use the hosted version available through ghcr:

```bash
docker pull ghcr.io/watzon/paste69:main
docker run -d -p 8080:8080 ghcr.io/watzon/paste69:main
```

All configuration items are available through environment variables, in addition to the config file. Configuration items and their environment variable names are listed below.

## Configuration

I've done my best to make Paste69 as zero configuration as possible. The default values listed in [src/services/config_manager.cr](src/services/config_manager.cr) should be sufficient for most deployments. However, should you wish to change any of the values you can do so through a config file, or using environment variables.

Valid config file locations are:

- /etc/paste69/config.yml
- ~/.paste69/config.yml
- ~/.config/paste69/config.yml

The following table contains all available configuration options, their default values, and their environment variable counterparts:

| Config Item                | Default Value             | Environment Variable       | Description                                         |
|----------------------------|---------------------------|----------------------------|-----------------------------------------------------|
| `host`                     | `"0.0.0.0"`               | `HOST`                     | Host to bind to                                     |
| `port`                     | `8080`                    | `PORT`                     | Port to bind to                                     |
| `site_url`                 | `"0.0.0.0:8080"`          | `SITE_URL`                 | Public URL of the site (used for generating links)  |
| `database_url`             | `"sqlite://./db/data.db"` | `DATABASE_URL`             | URL of the database (Postgres and SQLite supported) |
| `templates_dir`            | `"src/templates"`         | `TEMPLATES_DIR`            | Directory for template overrides (jinja2 format)    |
| `max_content_length`       | `256 * 1024 * 1024`       | `MAX_CONTENT_LENGTH`       | Maximum size for incoming files                     |
| `max_url_length`           | `4096`                    | `MAX_URL_LENGTH`           | Maximum size for shortened URLs                     |
| `max_ext_length`           | `9`                       | `MAX_EXT_LENGTH`           | Maximum size for file extensions                    |
| `storage.path`             | `"./uploads"`             | `STORAGE.PATH`             | Local storage path for files                        |
| `storage.type`             | `"local"`                 | `STORAGE.TYPE`             | Type of storage to use (local or s3)                |
| `storage.s3.region`        | `nil`                     | `STORAGE.S3.REGION`        | S3 region                                           |
| `storage.s3.bucket`        | `nil`                     | `STORAGE.S3.BUCKET`        | S3 bucket                                           |
| `storage.s3.access_key`    | `nil`                     | `STORAGE.S3.ACCESS_KEY`    | S3 access key                                       |
| `storage.s3.secret_key`    | `nil`                     | `STORAGE.S3.SECRET_KEY`    | S3 secret key                                       |
| `storage.secret_bytes`     | `16`                      | `STORAGE.SECRET_BYTES`     | Number of bytes to use for secrets                  |
| `storage.ext_override`     | _too long_                | `STORAGE.EXT_OVERRIDE`     | File extension override map (mime => ext)           |
| `storage.mime_blocklist`   | _too long_                | `STORAGE.MIME_BLOCKLIST`   | Array containing mime types to blocklist            |
| `storage.upload_blocklist` | `nil`                     | `STORAGE.UPLOAD_BLOCKLIST` | Path to a file containing banned IP addresses       |
| `nsfw.detect`              | `false`                   | `NSFW.DETECT`              | Enable NSFW detection (TODO)                        |
| `nsfw.threshold`           | `0.608`                   | `NSFW.THRESHOLD`           | NSFW detection threshold                            |
| `vscan.socket`             | `nil`                     | `VSCAN.SOCKET`             | ClamAV socket for virus scanning (TODO)             |
| `vscan.quarantine_path`    | `"./quarantine"`          | `VSCAN.QUARANTINE_PATH`    | Path for quarantined files                          |
| `vscan.interval`           | `604800`                  | `VSCAN.INTERVAL`           | How often to scan for viruses                       |
| `vscan.ignore`             | _too long_                | `VSCAN.IGNORE`             | Mime types for which to ignore virus scanning       |
| `url_alphabet`             | `"01234567890abcdef..."`  | `URL_ALPHABET`             | Alphabet string to use for shortened URL creation   |

### Custom Templates

Paste69 supports custom templates, which can be used to override the default templates. To do this, simply create a directory somewhere and copy the default templates from [src/templates](src/templates) into it. For example:

```bash
mkdir -p ~/.config/paste69/templates
cp -r ./src/templates ~/.config/paste69/templates
```

and then update your config file (or set the TEMPLATES_DIR environment variable) to point to the new location.

```diff
*** ~/.config/paste69/config.yml 2024-01-01 12:00:00.000000000 -0500
--- ~/.config/paste69/config.yml 2024-01-01 12:00:00.000000000 -0500
@@ -1,1 +1,1 @@
-templates_dir: "src/templates"
+templates_dir: "~/.config/paste69/templates"
```

this directory will be used __in stead of__ the default templates, and not in addition to, so be sure to copy all of the templates over.

### IP Blocklisting

IP blocklisting is supported. All uploads database entries _should_ contain an IP address, telling you where it was uploaded from. If you want to block a certain IP address (or even an entire subnet), you can create a file containing a list of IP addresses to block and upadate your config file with the path to the file. The file should contain a single IP address or subnet per line. For example:

```text
192.168.1.1
172.16.17.32/24
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
