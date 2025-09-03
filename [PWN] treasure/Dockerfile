FROM ubuntu:18.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qy xinetd\
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m chal

COPY share/ /home/chal/
COPY xinetd /etc/xinetd.d/chal

RUN chown -R root:root /home/chal \
    && chmod -R 755 /home/chal \
    && chmod +x /home/chal/run.sh \
    && chmod +x /home/chal/treasure

EXPOSE 40001

CMD ["/usr/sbin/xinetd", "-dontfork"]
