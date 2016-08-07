FROM resin/edison-python:latest

MAINTAINER Gergely Imreh <gergely@resin.io>

ENV INITSYSTEM on

WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get install -q -y \
      build-essential \
      automake \
      cmake \
      git \
      byacc \
      python-dev \
      libpcre++-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV SWIGVERSION rel-3.0.10
RUN git clone https://github.com/swig/swig.git && \
    cd swig && \
    git checkout ${SWIGVERSION} && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd .. && rm -rf swig

ENV MRAACOMMIT 29be2b64c050be3899da138c1d9a868327db2c95
RUN git clone https://github.com/intel-iot-devkit/mraa.git && \
    cd mraa && \
    git checkout -b build ${MRAACOMMIT} && \
    mkdir build && \
    cd build && \
    cmake .. -DSWIG_DIR=`swig -swiglib` \
      -DBUILDSWIGPYTHON=ON -DBUILDSWIGNODE=OFF -DBUILDSWIGJAVA=OFF && \
    make && \
    make install &&
    cd ../.. && rm -rf mraa

# Update commit if need to recompile library
ENV UPMCOMMIT 4faa71d239f3549556a61df1a9c6f81c3d06bda2
RUN git clone https://github.com/intel-iot-devkit/upm.git && \
    cd upm && \
    git checkout -b build ${UPMCOMMIT} && \
    mkdir build && \
    cd build && \
    cmake .. -DSWIG_DIR=`swig -swiglib` \
      -DBUILDSWIGPYTHON=ON -DBUILDSWIGNODE=OFF -DBUILDSWIGJAVA=OFF && \
    make && \
    make install &&
    cd ../.. && rm -rf upm

COPY requirements.txt ./

RUN pip install -r requirements.txt

ADD . ./

CMD ["bash", "start.sh"]
