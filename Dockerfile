FROM ubuntu:26.04 AS build

WORKDIR /root

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

RUN mv /usr/lib/python3.14/EXTERNALLY-MANAGED /usr/lib/python3.14/EXTERNALLY-MANAGED.old && \
    pip3 install meson

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
    libtiff-dev \
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
    libmagickcore-7.q16-dev \
    && apt autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG VIPS_VERSION
RUN VIPS_VERSION=${VIPS_VERSION:-$(curl -s https://api.github.com/repos/libvips/libvips/releases/latest | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')} && \
    wget "https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz" && \
    tar xf "vips-${VIPS_VERSION}.tar.xz" && \
    cd "/root/vips-${VIPS_VERSION}" && \
    meson setup build --libdir=lib --buildtype=release -Dintrospection=disabled && \
    cd "/root/vips-${VIPS_VERSION}/build" && \
    meson compile && \
    meson install && \
    ldconfig && \
    cd /root && rm "vips-${VIPS_VERSION}.tar.xz" && rm -rf "vips-${VIPS_VERSION}"

RUN mkdir -p /lib/x86_64-linux-gnu && mkdir -p /lib/aarch64-linux-gnu
RUN mkdir -p /usr/lib/x86_64-linux-gnu && mkdir -p /usr/lib/aarch64-linux-gnu


FROM ubuntu:26.04

RUN apt update -y && \
    apt install -y fontconfig && \
    apt autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/bin/vips* /usr/local/bin/
COPY --from=build /usr/bin /usr/bin
COPY --from=build /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=build /lib/aarch64-linux-gnu /lib/aarch64-linux-gnu
COPY --from=build /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=build /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu
COPY --from=build /usr/share/color /usr/share/color
COPY --from=build /usr/share/mime /usr/share/mime
COPY --from=build /etc /etc

CMD exec /bin/bash -c "fc-cache -f && trap : TERM INT; sleep infinity & wait"
