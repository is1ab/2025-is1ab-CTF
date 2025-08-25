#!/bin/bash
docker rm -f BabyShell
docker build -t BabyShell . && \
docker run --name=BabyShell --rm -p1337:80 -it BabyShell