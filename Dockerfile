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

# For MRAAVERSION can use tag or commit hash
ENV MRAAVERSION v1.2.1
RUN git clone https://github.com/intel-iot-devkit/mraa.git && \
    cd mraa && \
    git checkout -b build ${MRAACOMMIT} && \
    mkdir build && \
    cd build && \
    cmake .. -DSWIG_DIR=`swig -swiglib` \
      -DBUILDSWIGPYTHON=ON -DBUILDSWIGNODE=OFF -DBUILDSWIGJAVA=OFF && \
    make && \
    make install && \
    cd ../.. && rm -rf mraa

# For UPMVERSION can use tag or commit hash
ENV UPMVERSION v0.7.3
RUN git clone https://github.com/intel-iot-devkit/upm.git && \
    cd upm && \
    git checkout -b build ${UPMCOMMIT} && \
    mkdir build && \
    cd build && \
    cmake .. -DSWIG_DIR=`swig -swiglib` \
      -DBUILDSWIGPYTHON=ON -DBUILDSWIGNODE=OFF -DBUILDSWIGJAVA=OFF && \
    make && \
    make install && \
    cd ../.. && rm -rf upm

COPY requirements.txt ./

RUN pip install -r requirements.txt

ADD . ./

CMD ["bash", "start.sh"]
