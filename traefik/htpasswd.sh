#!/usr/bin/env bash

set -e 

docker run --rm -it --entrypoint /usr/local/apache2/bin/htpasswd httpd:alpine -nb $@
