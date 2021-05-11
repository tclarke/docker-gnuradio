ARG ARCH=
#FROM navikey/raspbian-buster
FROM ${ARCH}debian:buster-slim

RUN apt update --allow-releaseinfo-change && \
    apt upgrade -qy && \
    apt install -qy git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
        python3-lxml libfftw3-dev \
        libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
        liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
        python3-zmq python3-scipy libpthread-stubs0-dev libusb-1.0-0 libusb-1.0-0-dev \
        libudev-dev python3-setuptools python-docutils build-essential liborc-0.4-0 liborc-0.4-dev \
        python3-gi-cairo python3-mako

RUN git clone --recursive https://github.com/gnuradio/volk.git && \
    mkdir volk/build && \
    cd volk/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_INSTALL_PREFIX=/usr ../ && \
    make -j3 install

RUN git clone --recursive https://github.com/pybind/pybind11.git --branch v2.4.0 && \
    mkdir pybind11/build && \
    cd pybind11/build && \
    cmake -DPYBIND11_TEST=OFF -DCMAKE_INSTALL_PREFIX=/usr ../ && \
    make -j3 install

RUN git clone https://github.com/gnuradio/gnuradio.git && \
    mkdir gnuradio/build && \
    cd gnuradio/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_INSTALL_PREFIX=/usr ../ && \
    make -j3 install && \
    ldconfig

RUN cd && rm -rf gnuradio pybind11 volk
