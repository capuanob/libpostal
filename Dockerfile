# Build Stage
ARG BUILD_VERSION="release"

FROM --platform=linux/amd64 ubuntu:20.04 as base

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git build-essential curl autoconf automake libtool pkg-config

FROM base AS src-debug
WORKDIR /
ADD . /libpostal
WORKDIR /libpostal

FROM base AS src-release

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/libpostal.git
WORKDIR /libpostal
RUN git checkout mayhem

FROM src-${BUILD_VERSION} AS builder

## Build
RUN ./bootstrap.sh
RUN mkdir db && ./configure CC=clang CFLAGS="-fsanitize=fuzzer-no-link" LDFLAGS="-fsanitize=fuzzer-no-link" --datadir=/libpostal/db
RUN make -j$(nproc)
RUN make install && ldconfig

## Build fuzzer
WORKDIR fuzz
RUN clang -fsanitize=fuzzer `pkg-config --cflags --libs libpostal` fuzz.c -o postal-fuzz

## Create symbolic links, as package stage is redundant. Huge dependencies regardless
RUN ln -s /libpostal/fuzz/postal-fuzz /postal-fuzz
RUN ln -s /libpostal/fuzz/corpus /corpus

## Set up fuzzing!
ENTRYPOINT []
CMD /postal-fuzz /corpus -close_fd_mask=2
