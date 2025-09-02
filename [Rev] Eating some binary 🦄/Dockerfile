FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y software-properties-common build-essential ncat && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    rm -rf /var/lib/apt/lists/*

COPY main.cpp /main.cpp
COPY include /include
COPY lib /lib

RUN g++ -I/include -Wall -Wextra -lm /main.cpp -o /main -g -L/lib -lunicorn 

EXPOSE 80
ENV FLAG=is1ab{Un1c0rn_f345ts_0n_b1n4ry!}
CMD ncat -l -p 80 --sh-exec "/main $FLAG" --keep-open

# g++ -I./include -Wall -Wextra -lm ./main.cpp -o ./main -g -L./lib -lunicorn --static
