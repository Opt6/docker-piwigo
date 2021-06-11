# FROM php:7.4-fpm-alpine

# RUN \
  # echo "**** install custom packages ****" && \
  # apk add --no-cache --upgrade \
        # libzip-dev \
        # zip \
    # && docker-php-ext-configure zip --with-zlib-dir=/usr \
    # && docker-php-ext-install -j$(nproc) zip

# FROM php:7.4-fpm-alpine

# COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# RUN apk add --no-cache libzip-dev && docker-php-ext-install zip

#RUN install-php-extensions zip && docker-php-ext-configure zip --with-libzlib

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PIWIGO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache --upgrade \
    curl \
    exiftool \
    ffmpeg \
    imagemagick \
    libjpeg-turbo-utils \
    libzip-dev \
    lynx \
    mediainfo \
    php7-apcu \
    php7-cgi \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-gd \
    php7-imagick \
    php7-ldap \
    php7-mysqli \
    php7-mysqlnd \
    php7-pear \
    php7-xmlrpc \
    php7-xsl \
    poppler-utils \
    re2c \
    unzip \
    wget &&\

  curl -o \
    /install-php-extensions -L \
    "https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions" && \
  chmod +x /install-php-extensions \
RUN \  
  install-php-extensions zip \
  
RUN \
  echo "**** download piwigo ****" && \
  if [ -z ${PIWIGO_RELEASE+x} ]; then \
    PIWIGO_RELEASE=$(curl -sX GET "https://api.github.com/repos/Piwigo/Piwigo/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir /piwigo && \
  curl -o \
    /piwigo/piwigo.zip -L \
    "http://piwigo.org/download/dlcounter.php?code=${PIWIGO_RELEASE}" && \
  # The max filesize is 2M by default, which is way to small for most photos
  sed -ri 's/^upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php7/php.ini && \
  # The max post size is 8M by default, it must be at least max_filesize
  sed -ri 's/^post_max_size = .*/post_max_size = 100M/' /etc/php7/php.ini

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config /gallery
