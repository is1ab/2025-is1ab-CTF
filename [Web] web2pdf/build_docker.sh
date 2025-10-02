#!/bin/bash

docker build -t web2pdf .

docker run --rm -dit --name=web2pdf -e 'OPENSSL_CONF=/etc/ssl' web2pdf
