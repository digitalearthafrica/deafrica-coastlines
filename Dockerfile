FROM ghcr.io/osgeo/gdal:ubuntu-small-3.7.3 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update \
    && apt-get install -y \
    # Build tools
    build-essential \
    git \
    python3-pip \
    # For Psycopg2
    libpq-dev python3-dev \
    # For SSL
    ca-certificates \
    # Tidy up
    && apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

WORKDIR /code
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir uv

COPY requirements.in /code/requirements.in

RUN uv pip compile requirements.in \
        --extra-index-url https://packages.dea.ga.gov.au/ \
        -o requirements.txt \
    && uv pip install -r requirements.txt \
        --extra-index-url https://packages.dea.ga.gov.au/ \
        --system

COPY . /code/

RUN uv pip install . --system \
    && uv pip check

CMD ["python", "--version"]

RUN deafricacoastlines-raster --help \
    && deafricacoastlines-vector --help
