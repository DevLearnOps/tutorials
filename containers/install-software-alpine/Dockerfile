FROM alpine:3.17

# Install `curl` to perform some installation step,
# uninstall `curl` as not needed to run the application
# and cleanup repository cache
RUN apk update \
    && apk add curl \
    && echo "Do something with curl" \
    && apk del curl \
    && rm -rf /var/cache/apk

# Make sure community repository is enabled.
# This is not always necessary though when building upon existing images
# some repositories could have been disabled for security purposes
RUN VERSION="v$(cut -d'.' -f1,2 /etc/alpine-release)" \
    && echo "https://dl-cdn.alpinelinux.org/alpine/$VERSION/main/" > /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/$VERSION/community/" >> /etc/apk/repositories

# Install Nginx web server.
# No need to build or cleanup the cache when using the `--no-cache` option
# Preferred method to install packages in Dockerfiles
RUN apk add --no-cache nginx

COPY 10-default-site.conf /etc/nginx/http.d/default.conf
COPY index.html /www/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
