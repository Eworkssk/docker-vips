FROM ubuntu:22.04

# Versions
ENV LIBVIPS_VERSION=8.14.4 \
    MOZJPEG_VERSION=4.1.1 \
    LIBSPNG_VERSION=0.7.4 \
    LIBCGIF_VERSION=0.3.2 \
    LIBRSVG_VERSION=2.56 \
    LIBRSVG_VERSION_PATCH=2.56.92 \
    CAIRO_VERSION=1.17.8

ARG DEBIAN_FRONTEND=noninteractive

# Install prequisites
RUN apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y \
        curl git wget ca-certificates xz-utils zlib1g-dev \
        cmake autoconf automake libtool nasm make pkg-config \
        meson build-essential libglib2.0-dev libexpat1-dev \
        libfftw3-dev liborc-0.4-dev liblcms2-dev librust-pangocairo-dev libfontconfig-dev \
        libexif-dev libpng-dev libopenjp2-7-dev libpng-dev libtiff-dev libgsf-1-dev libheif-dev libwebp-dev \
        libpoppler-glib-dev librsvg2-dev libopenexr-dev libmatio-dev libcfitsio-dev \ 
        libopenslide-dev libimagequant-dev webp-pixbuf-loader \
        ghostscript libfreetype6-dev libgomp1 libpng16-16 libxml2-dev libxml2-utils libmagickcore-dev libmagick++-dev && \
    apt-get clean
    
# Install mozjpeg
RUN wget https://github.com/mozilla/mozjpeg/archive/refs/tags/v${MOZJPEG_VERSION}.tar.gz -O mozjpeg-${MOZJPEG_VERSION}.tar.gz && \
    tar xvzf mozjpeg-${MOZJPEG_VERSION}.tar.gz && \
    cd mozjpeg-${MOZJPEG_VERSION} && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j16 && \
    make install # && \
    cd ../.. && rm -rf mozjpeg-${MOZJPEG_VERSION} && rm mozjpeg-${MOZJPEG_VERSION}.tar.gz
    
# Install libspng
RUN wget https://github.com/randy408/libspng/archive/refs/tags/v${LIBSPNG_VERSION}.tar.gz -O libspng-${LIBSPNG_VERSION}.tar.gz && \
    tar xvzf libspng-${LIBSPNG_VERSION}.tar.gz && \
    cd libspng-${LIBSPNG_VERSION} && \
    CFLAGS="-O3 -DSPNG_SSE=4" meson setup _build --default-library=static --buildtype=release --prefix=/usr/local --strip \
        -Dstatic_zlib=true && \
    meson install -C _build --tag devel && \
    cd .. && rm -rf libspng-${LIBSPNG_VERSION} && rm libspng-${LIBSPNG_VERSION}.tar.gz
    
# Install cgif
RUN wget https://github.com/dloebl/cgif/archive/refs/tags/V${LIBCGIF_VERSION}.tar.gz -O libcgif-${LIBCGIF_VERSION}.tar.gz && \
    tar xvzf libcgif-${LIBCGIF_VERSION}.tar.gz && \
    cd cgif-${LIBCGIF_VERSION} && \
    CFLAGS="-O3" meson setup _build --default-library=static --buildtype=release --prefix=/usr/local --strip \
        -Dtests=false && \
    meson install -C _build --tag devel && \
    cd .. && rm -rf cgif-${LIBCGIF_VERSION} && rm libcgif-${LIBCGIF_VERSION}.tar.gz
    
# Install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cairo
RUN wget https://gitlab.freedesktop.org/cairo/cairo/-/archive/${CAIRO_VERSION}/cairo-${CAIRO_VERSION}.tar.bz2 -O cairo-${CAIRO_VERSION}.tar.bz2 && \
    tar xvf cairo-${CAIRO_VERSION}.tar.bz2 && \
    cd cairo-${CAIRO_VERSION} && \
    meson setup _build --default-library=static --buildtype=release --strip --prefix=/usr/local \
        -Dquartz=disabled -Dxcb=disabled -Dxlib=disabled -Dzlib=disabled \
        -Dtests=disabled -Dspectre=disabled -Dsymbol-lookup=disabled && \
    meson install -C _build --tag devel && \
    cd .. && rm -rf cairo-${CAIRO_VERSION} && rm cairo-${CAIRO_VERSION}.tar.bz2
    
# Install librsvg2
RUN wget https://download.gnome.org/sources/librsvg/${LIBRSVG_VERSION}/librsvg-${LIBRSVG_VERSION_PATCH}.tar.xz -O librsvg-${LIBRSVG_VERSION_PATCH}.tar.xz && \
    tar xvf librsvg-${LIBRSVG_VERSION_PATCH}.tar.xz && \
    cd librsvg-${LIBRSVG_VERSION_PATCH} && \
    sed -i'.bak' "s/^\(Requires:.*\)/\1 cairo-gobject pangocairo libxml-2.0/" librsvg.pc.in && \
    sed -i'.bak' "/crate-type = /s/, \"rlib\"//" librsvg-c/Cargo.toml && \
    sed -i'.bak' "/cairo-rs = /s/ \"pdf\", \"ps\",//" librsvg-c/Cargo.toml && \
    sed -i'.bak' "/cairo-rs = /s/ \"pdf\", \"ps\",//" rsvg/Cargo.toml && \
    ./configure --prefix=/usr/local --enable-static --disable-shared --disable-dependency-tracking \
        --disable-introspection --disable-pixbuf-loader && \
    cd .. && rm -rf librsvg-${LIBRSVG_VERSION_PATCH} && rm librsvg-${LIBRSVG_VERSION_PATCH}.tar.xz
    
# Install libvips
RUN wget https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.xz && \
    tar xf vips-${LIBVIPS_VERSION}.tar.xz && \
    cd vips-${LIBVIPS_VERSION} && \
    meson setup build --libdir=lib --buildtype release -Dintrospection=false && \
    cd build && \
    ninja && \
    ninja install && \
    cd ../.. && rm -rf vips-${LIBVIPS_VERSION} && rm vips-${LIBVIPS_VERSION}.tar.xz
