#!/bin/bash
docker rm -f web_404_j0b_b4nk
docker build -t web_404_j0b_b4nk .
docker run --name=web_404_j0b_b4nk --rm -p1337:1337 -it web_404_j0b_b4nk
