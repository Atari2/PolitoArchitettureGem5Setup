FROM ubuntu:22.04 AS base
RUN apt-get update
RUN apt-get -y install libzstd-dev libgmp-dev libmpfr-dev libmpc-dev flex git curl dos2unix
RUN git clone --branch releases/gcc-7.3.0 --depth 1 https://gcc.gnu.org/git/gcc.git
RUN curl https://raw.githubusercontent.com/Atari2/PolitoArchitettureGem5Setup/refs/heads/master/gcc730.patch -o gcc730.patch
RUN dos2unix gcc730.patch
WORKDIR /gcc
RUN git apply ../gcc730.patch
RUN mkdir build && cd build
WORKDIR  /gcc/build
RUN ../configure --disable-multilib --enable-languages=c,c++ --prefix=/gcc-730
RUN make -j$(nproc)
RUN make install