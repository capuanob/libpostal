# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git build-essential curl autoconf automake libtool pkg-config

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/libpostal.git
WORKDIR /libpostal
RUN git checkout mayhem

## Build
RUN make distclean
RUN ./bootstrap.sh
RUN mkdir db && ./configure CC=clang CFLAGS="-fsanitize=fuzzer-no-link" LDFLAGS="-fsanitize=fuzzer-no-link" --datadir=/libpostal/db
RUN make -j$(nproc) && make install && ldconfig

# Package Stage
#RUN mkdir /corpus
#FROM --platform=linux/amd64 ubuntu:20.04
#COPY --from=builder /libyuarel/yuarel-fuzz /
#COPY --from=builder /libyuarel/fuzz/corpus /corpus
#COPY --from=builder /usr/lib/libyuarel.so.1 /usr/lib

## Set up fuzzing!
#ENTRYPOINT []
#CMD /yuarel-fuzz /corpus -close_fd_mask=2
