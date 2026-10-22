# Docker Images for Laravel development
This repository provides you a development environment without requiring you to install PHP, a web server, and any other server software on your local machine. For this, it requires Docker and Docker Compose.

## Philosophy

When using docker images for development, we want to bind our source directories to the source directories on the host.

When using docker images for production, we want to copy our source directories to an image built on top of the base images that we used for development.

The docker images in this repository are for development purposes, and serve as the foundation for the production images.

## Installation

1. Install [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/) ;

2. Copy `docker-compose.yml` file to your project root path, and edit it according to your needs ;

3. Authenticate with docker
```
aws ecr get-login-password --profile senseme | docker login --username AWS --password-stdin 903045850431.dkr.ecr.us-east-1.amazonaws.com

```

4. From your project directory, start up your application by running:

```sh
docker-compose up
```
5. If you want, you can run composer or artisan through docker. For instance:

```sh
docker-compose exec app composer install
docker-compose exec app php artisan migrate
docker-compose exec app $yourCommandHere
```

## NGINX Image

This project uses the official NGINX image on alpine.  To configure the NGINX image, you may want to map or copy your own conf file in place of `/etc/nginx/nginx.conf`.  You may also want to add additional files in `/etc/nginx/conf.d`.  This can include your own `default.conf` and other configuration files.


## Docker Image

These docker images are configured in `docker-compose.yml` file.
You can comment or uncomment some services according to your project.

* `laravel-php:<version>` ; # the Base image: PHP 7.4.33 built from source with the official CVE-2026-109618/109619 backport, plus the extensions, php.ini and tools (Composer 1.9.3, Node 10) every App image needs. Source: `php-fpm/7.4`
* `nginx:1.13-alpine` ;  # this is the official docker image for nginx and can be used as a foundation for production images
* `mysql:5.7` ;          # development purposes only
* `redis:4.0-alpine` ;   # development purposes only

`php-fpm/7.3`, `php-cli/7.3` and `php-cli/7.4` are the previous images and are no longer maintained.

Why we build PHP ourselves: [docs/adr/0001-build-php-from-official-backport.md](docs/adr/0001-build-php-from-official-backport.md). Background and rollout plan: [docs/php-7.4-cve-migration.md](docs/php-7.4-cve-migration.md).

## Building the PHP Image

```bash
cd php-fpm/7.4
make build   # build for linux/amd64 (the first build compiles PHP, ~3-5 minutes)
make test    # check the image: PHP + backport, extensions, php.ini, tools
```

To publish, bump the version in `config.env`, then:

```bash
make release   # build without cache, test, push `<version>` to ECR, print the digest
```

Only the immutable `<version>` tag is published (no `latest`, `MAJOR` or `MAJOR.MINOR` tags), and `make publish` refuses to overwrite a version that already exists in ECR. App images pin the Base image by tag **and** digest, using the line `make publish` prints:

```dockerfile
FROM 903045850431.dkr.ecr.us-east-1.amazonaws.com/laravel-php:9.0.0@sha256:<digest>
```

### Updating the PHP patch

`php-fpm/7.4/php/` holds the `docker-php-*` scripts from docker-library (`github.com/docker-library/php` at `f2999de8^`, `7.4/alpine3.16/fpm`) and the backport patch. To pick up a new upstream backport, export it from php-src with `git format-patch -1 <commit>`, then update the patch file and `PHP_CVE_PATCH_SHA256` in the Dockerfile.

## Contributing

Contributions are welcome!
Leave an issue on Github, or create a Pull Request.


## Licence

This work is under [MIT](LICENCE) licence.
