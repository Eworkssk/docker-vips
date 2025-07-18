FROM ubuntu:24.04 as build

WORKDIR /root

# Install build tools
RUN apt update -y && \
    apt install -y software-properties-common \
    cmake \
    pkg-config \
    libglib2.0-dev \
    build-essential \
    ninja-build \
    python3-pip \
    bc \
    wget \
    curl \
    zip \
    unzip \
    tar && \
    apt autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.old && \
    pip3 install meson

# Install libvips libraries
RUN apt update -y && \
    apt install -y libfftw3-dev \
    libhwy-dev \
    libopenexr-dev \
    libgsf-1-dev \
    libjpeg-turbo8-dev \
    libwebp-dev \
    libopenslide-dev \
    libmatio-dev \
    libexpat1-dev \
    libexif-dev \
    libtiff5-dev \
    libcfitsio-dev \
    librsvg2-dev \
    libpango1.0-dev \
    libopenjp2-7-dev \
    liblcms2-dev \
    libimagequant-dev \
    libjxl-dev \
    zlib1g-dev \
    libpng-dev \
    libheif-dev \
    libpoppler-glib-dev \
    libcgif-dev \
    libde265-dev \
    libx265-dev \
    libheif-plugin-* \
    libmagickcore-6.q16-dev \
    && apt autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install libvips
RUN cd /root && \
    wget https://github.com/libvips/libvips/releases/download/v8.17.0/vips-8.17.0.tar.xz && \
    tar xf vips-8.17.0.tar.xz && \
    cd /root/vips-8.17.0 && \
    meson setup build --libdir=lib --buildtype=release -Dintrospection=disabled && \
    cd /root/vips-8.17.0/build && \
    meson compile && \
    meson install && \
    ldconfig && \
    cd /root && rm vips-8.17.0.tar.xz && rm -rf vips-8.17.0

RUN mkdir -p /lib/x86_64-linux-gnu && mkdir -p /lib/aarch64-linux-gnu
RUN mkdir -p /usr/lib/x86_64-linux-gnu && mkdir -p /usr/lib/aarch64-linux-gnu


FROM ubuntu:24.04

COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/bin/vips* /usr/local/bin/
COPY --from=build /usr/bin /usr/bin
COPY --from=build /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=build /lib/aarch64-linux-gnu /lib/aarch64-linux-gnu
COPY --from=build /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=build /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu
COPY --from=build /usr/share/color /usr/share/color
COPY --from=build /usr/share/ghostscript /usr/share/ghostscript
COPY --from=build /usr/share/poppler /usr/share/poppler
COPY --from=build /usr/share/mime /usr/share/mime
COPY --from=build /etc /etc

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
