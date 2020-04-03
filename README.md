# Docker Images for Laravel development
This repository provides you a development environment without requiring you to install PHP, a web server, and any other server software on your local machine. For this, it requires Docker and Docker Compose.


## Installation

1. Install [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/) ;

2. Copy `docker-compose.yml` file to your project root path, and edit it according to your needs ;

3. From your project directory, start up your application by running:

```sh
docker-compose up
```
4. If you want, you can run composer or artisan through docker. For instance:

```sh
docker-compose exec php composer install
docker-compose exec php php artisan migrate
docker-compose exec php $yourCommandHere
```


## Docker Images

These docker images are configured in `docker-compose.yml` file.
You can comment or uncomment some services according to your project.

* [`laravel-php:7.3`](https://hub.docker.com/r/jguyomard/laravel-php/) (this docker image extends `php:7.3-fpm-alpine` to add some PHP extensions) ;
* [`laravel-nginx:1.13`](https://hub.docker.com/r/jguyomard/laravel-nginx/) (this docker image extends `nginx:1.13-alpine` to add Laravel vhost) ;
* `mysql:5.7` ;
* `redis:4.0-alpine` ;

## Building the PHP Image

```bash
cd php/7.3
make build # build the image
```
You can test the image locally.  When you are happy with it you can update the version in config.env

To publish the image to the repository with semantic versioned tags, run:
```
make publish
```

For version 1.2.3 this will tag the images as `latest`, `1.2.3`, `1.2` and `1`.  If you need to publish some subset of these, you can manually publish as appropriate.

You can see a variety of options by running `make` or `make help`

```
help                           This help.
build                          Build the container
build-nc                       Build the container without caching
run                            Run container on port configured in `config.env`
up                             Run container on port configured in `config.env` (Alias to run)
stop                           Stop and remove a running container
release                        Make a release by building and publishing tagged containers to ECR
publish                        Publish `latest` and semantic version tagged containers to ECR
publish-latest                 Publish the `latest` tagged container to ECR
publish-version                Publish the `{version}` tagged container to ECR
publish-major                  Publish the `MAJOR` tagged container to ECR
publish-major-minor            Publish the `MAJOR.MINOR` tagged container to ECR
tag                            Generate container tags for the `{version}` and `latest` tags
tag-latest                     Generate container `{version}` tag
tag-version                    Generate container `latest` tag
tag-major                      Generate container `major` tag
tag-major-minor                Generate container `major.minor` tag
repo-login                     Auto login to AWS-ECR unsing aws-cli
```
To pull the php image from the repo, use the following command.

`docker pull 903045850431.dkr.ecr.us-east-1.amazonaws.com/laravel-php:latest`


## Contributing

Contributions are welcome!
Leave an issue on Github, or create a Pull Request.


## Licence

This work is under [MIT](LICENCE) licence.
