FROM python:3.9-slim AS builder

RUN apt update --allow-releaseinfo-change && \
    apt install -qy build-essential git cmake libboost-all-dev libgmp-dev \
                    libzmq3-dev libpthread-stubs0-dev libusb-1.0-0 libusb-1.0-0-dev \
                    libudev-dev liborc-0.4-0 liborc-0.4-dev swig libfftw3-dev \
                    pkg-config libspdlog-dev

COPY requirements.txt /tmp/requirements.txt
RUN /usr/local/bin/python3 -mpip install --no-cache-dir -r /tmp/requirements.txt && \
    /usr/local/bin/python3 -mpip install --no-cache-dir -r /tmp/requirements.txt --prefix=/staging 

RUN git clone --recursive https://github.com/gnuradio/volk.git --branch v2.5.1 && \
    mkdir volk/build && \
    cd volk/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/local/bin/python3 -DCMAKE_INSTALL_PREFIX=/usr ../ && \
    make -j3 install && \
    make DESTDIR=/stage install

RUN git clone --recursive https://github.com/pybind/pybind11.git --branch v2.4.0 && \
    mkdir pybind11/build && \
    cd pybind11/build && \
    cmake -DPYBIND11_TEST=OFF -DCMAKE_INSTALL_PREFIX=/usr ../ && \
    make -j3 install && \
    make -j3 DESTDIR=/stage install

RUN git clone https://github.com/gnuradio/gnuradio.git --branch v3.10.3.0 && \
    ln -s $(/usr/local/bin/python -c "import numpy;print(numpy.get_include())")/numpy /usr/include && \
    mkdir gnuradio/build && \
    cd gnuradio/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/local/bin/python3 \
          -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_GR_ZEROMQ=ON ../ && \
    make -j3 DESTDIR=/stage install


FROM python:3.9-slim

RUN apt update --allow-releaseinfo-change && \
    apt install -qy libzmq5 libusb-1.0-0 libudev1 liborc-0.4-0 fftw3 libspdlog-dev \
                    libboost-thread1.74.0 libboost-program-options1.74.0

COPY --from=builder /stage/ /
RUN ldconfig
