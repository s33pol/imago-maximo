# QPID (Debian)
# Build Apache QPID CPP from source
FROM debian:10-slim AS qpid-build
ARG QPIDPROTON_VER="0.32.0"
ARG QPIDCPP_VER="1.39.0"

ENV DEBIAN_FRONTEND=noninteractive
# Get Apache QPID source tarballs
RUN apt-get update && apt-get install -y curl
WORKDIR /workspace
RUN curl  \
        ftp://ftp.mirrorservice.org/sites/ftp.apache.org/qpid/proton/$QPIDPROTON_VER/qpid-proton-$QPIDPROTON_VER.tar.gz \
        --output qpid-proton-$QPIDPROTON_VER.tar.gz
RUN curl  \
        ftp://ftp.mirrorservice.org/sites/ftp.apache.org/qpid/cpp/$QPIDCPP_VER/qpid-cpp-$QPIDCPP_VER.tar.gz \
        --output qpid-cpp-$QPIDCPP_VER.tar.gz
# Get required tooling
RUN apt-get install -y \
        cmake g++ python-dev ruby-dev \
        pkg-config doxygen valgrind \
        libsasl2-dev libboost-all-dev uuid-dev libnss3-dev swig libdb5.3-dev libdb5.3++-dev libaio-dev \
    && rm -rf /var/lib/apt/lists/*
# Build QPID-Proton; adds AMQP 1.0 capability
WORKDIR /workspace
RUN tar xf qpid-proton-$QPIDPROTON_VER.tar.gz
WORKDIR /workspace/qpid-proton-$QPIDPROTON_VER/build
RUN mkdir -p /opt/qpid-proton \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/qpid-proton/ .. \
    && make -j2 install/strip
# Build QPID-CPP
ENV PKG_CONFIG_PATH "/opt/qpid-proton/lib/pkgconfig"
WORKDIR /workspace
RUN tar xf qpid-cpp-$QPIDCPP_VER.tar.gz
# Build, does not support build as archive-libraries
WORKDIR /workspace/qpid-cpp-$QPIDCPP_VER/build
RUN mkdir -p /opt/qpid-cpp \
    && cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/opt/qpid-cpp/ \
    && make -j2 install/strip


# Debian extended with QPID Proton
FROM debian:10-slim
ARG QPIDPROTON_VER
ARG QPIDCPP_VER
LABEL description="Apache Proton; Debian base"
LABEL qpid_cpp=$QPIDCPP_VER
LABEL qpid_proton=$QPIDPROTON_VER
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
    libnss3 libboost-program-options1.67.0 libsasl2-2 libaio1 libdb5.3 libdb5.3++ \
    && rm -rf /var/lib/apt/lists/*
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/opt/qpid-cpp/lib:/opt/qpid-proton/lib"
COPY --from=qpid-build /opt/qpid-proton /opt/qpid-proton
COPY --from=qpid-build /opt/qpid-cpp /opt/qpid-cpp
