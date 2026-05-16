# libvips Docker Image

Minimal Ubuntu-based Docker image with [libvips](https://www.libvips.org/) compiled from source for headless/server use. Runs continuously, always ready to process — clients run commands without cold-start overhead using `docker exec`.

[![Build and Publish](https://github.com/eworkssk/docker-vips/actions/workflows/build.yml/badge.svg)](https://github.com/eworkssk/docker-vips/actions/workflows/build.yml)
![Docker Stars](https://img.shields.io/docker/stars/eworkssk/vips?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/eworkssk/vips?style=for-the-badge)
![Docker Image Size](https://img.shields.io/docker/image-size/eworkssk/vips/latest?style=for-the-badge)

## What's included

libvips compiled from the latest release with a wide set of format support libraries:

| Format / Feature | Library |
|-----------------|---------|
| JPEG | libjpeg-turbo |
| JPEG XL | libjxl |
| WebP | libwebp |
| PNG | libpng + zlib |
| TIFF | libtiff |
| HEIF / AVIF | libheif + plugins |
| OpenEXR | libopenexr |
| OpenJPEG | libopenjp2 |
| SVG / PDF render | librsvg, libpoppler |
| GIF | libcgif |
| ImageMagick | libmagickcore |
| Colour management | liblcms2 |
| Image quantization | libimagequant |
| FITS | libcfitsio |
| OpenSlide | libopenslide |
| MATLAB | libmatio |
| FFT | libfftw3 |

## Get it from

- [Docker Hub](https://hub.docker.com/r/eworkssk/vips): `eworkssk/vips`
- [GitHub Packages](https://github.com/eworkssk/docker-vips/pkgs/container/vips): `ghcr.io/eworkssk/vips`

### Choose the right tag

| Tag          | Description                          |
|--------------|--------------------------------------|
| `latest`     | Latest build                         |
| `8.18`       | Latest build of the 8.18.x line      |
| `8.18.2`     | Latest build of libvips 8.18.2       |
| `8.18.2-47`  | libvips 8.18.2, build #47            |

_Tags are examples — see [Docker Hub](https://hub.docker.com/r/eworkssk/vips) or [GitHub Packages](https://github.com/eworkssk/docker-vips/pkgs/container/vips) for current tags._

## Quick start

```bash
# Start the container
docker run -d --name vips eworkssk/vips:latest

# Check vips version
docker exec vips vips --version

# Convert image to WebP
docker exec vips vips copy /data/input.jpg /data/output.webp

# Resize image
docker exec vips vips thumbnail /data/input.jpg /data/thumb.jpg 300

# Open a shell
docker exec -it vips bash
```

## Docker Compose

```yaml
services:
  vips:
    image: eworkssk/vips:latest
    volumes:
      - ./files:/data
    restart: unless-stopped
```

## Mounting files

```bash
docker run -d --name vips -v /your/files:/data eworkssk/vips:latest
docker exec vips vips copy /data/input.jpg /data/output.webp
```

## Custom fonts

Mount a directory with your font files into `/usr/local/share/fonts/custom` — the font cache is rebuilt automatically on every container start.

```bash
docker run -d --name vips \
  -v /your/fonts:/usr/local/share/fonts/custom:ro \
  eworkssk/vips:latest
```

The `:ro` flag mounts fonts read-only. With Docker Compose:

```yaml
services:
  vips:
    image: eworkssk/vips:latest
    volumes:
      - ./files:/data
      - ./fonts:/usr/local/share/fonts/custom:ro
    restart: unless-stopped
```

## Builds

Images are built for `linux/amd64` and `linux/arm64` — works on standard x86-64 machines, ARM-based Linux servers, Apple Silicon, and Raspberry Pi.

Images are updated automatically every Tuesday at 03:00 UTC, always pulling the latest libvips release and Ubuntu security patches.

Build tags use the format `{vips_version}-{build_number}` (e.g. `8.18.2-47`).

---

## Maintained by EWORKS.sk

[<img src="https://raw.githubusercontent.com/eworkssk/docker-vips/master/public/eworks.png" alt="EWORKS.sk" height="80">](https://eworks.sk/)

We are building custom web and mobile apps for 20+ years. Check out [our website](https://eworks.sk/) for more.

This image runs in our own stack, which is why we keep it maintained. Issues and PRs are welcome and appreciated.
