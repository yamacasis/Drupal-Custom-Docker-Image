# Drupal Custom Docker Image

This repository contains a Dockerfile to build a custom Drupal image based on `php:8.3-fpm`. It includes necessary PHP extensions, Composer, and Drush.

## Features

- **Base Image:** PHP 8.3 FPM
- **Database Support:** PostgreSQL (`pgsql`, `pdo_pgsql`) and MySQL (`pdo_mysql`)
- **Extensions:** GD (with JPEG/FreeType), Intl, Mbstring, Zip, Exif, Pcntl, Opcache
- **Tools:** Composer, Drush, Git, Unzip, Vim
- **Image Optimization Tools:** jpegoptim, optipng, pngquant, gifsicle
- **Configuration:** Optimized Opcache settings for Drupal

## Building the Image

To build the Docker image, run the following command in the directory containing the Dockerfile:

```bash
docker build -t my-drupal-image .
```

## Running the Container

You can run the container using Docker:

```bash
docker run -d -p 9000:9000 --name drupal-app my-drupal-image
```

This will start PHP-FPM on port 9000. Note that this image only contains the PHP application. You will likely need a web server (like Nginx or Apache) and a database server to serve the application fully.

### Using with Docker Compose

Typically, you would use this image in a `docker-compose.yml` setup. Example:

```yaml
version: '3'
services:
  drupal:
    build: .
    volumes:
      - ./web:/var/www/html/web
    restart: always

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./web:/var/www/html/web
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - drupal

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: drupal
      POSTGRES_USER: drupal
      POSTGRES_PASSWORD: password
```

## Notes

- The image installs `drupal/recommended-project` by default into `/var/www/html`.
- Permissions for `web/sites/default/files` are set to `775` and owned by `www-data`.
- SSH key copying has been removed for security and portability. If you need private repositories, consider using Docker build secrets.
