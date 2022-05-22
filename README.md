# docker-rainloop

![](https://i.goopics.net/nI.png)

### What is this ?

Rainloop is a simple, modern & fast web-based client. More details on the [official website](http://www.rainloop.net/).

### Why these image:

A self-made image for testing prupose, to learn CI github process.

## Architectures

* [x] `arm64`
* [x] `amd64`

### Features

- Lightweight & secure image (no root process)
- Based on Alpine (php:8.1.6-fpm-alpine)
- Latest Rainloop (stable)

### Exposed Ports:
- 80

### Docker-compose.yml

```yml

rainloop:
  image: newargus/rainloop-webmail
  container_name: rainloop
  volumes:
    - /mnt/docker/rainloop/data:/var/www/html/data

```
#### How to setup

https://www.rainloop.net/docs/configuration/