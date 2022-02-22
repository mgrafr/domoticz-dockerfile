FROM debian:bullseye-slim

ARG APP_VERSION
ARG APP_HASH
ARG BUILD_DATE
# If stable argument is passed it will download stable instead of beta
ARG STABLE

LABEL org.label-schema.version=$APP_VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$APP_HASH \
      org.label-schema.vcs-url="https://github.com/mgrafr/domoticz" \
      org.label-schema.url="https://domoticz.com/" \
      org.label-schema.vendor="Domotic" \
      org.label-schema.name="domoticz" \
      org.label-schema.description="Domoticz open source Home Automation system>
      org.label-schema.license="GPLv3" \
      org.label-schema.docker.cmd="docker run -v ./config:/config -v ./plugins:>
      maintainer="Domoticz Docker Maintainers <info@domoticz.com>"

FROM debian:bullseye-slim

ARG APP_VERSION
ARG APP_HASH
ARG BUILD_DATE
# If stable argument is passed it will download stable instead of beta
ARG STABLE

LABEL org.label-schema.version=$APP_VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$APP_HASH \
      org.label-schema.vcs-url="https://github.com/mgrafr/domoticz" \
      org.label-schema.url="https://domoticz.com/" \
      org.label-schema.vendor="Domo" \
      org.label-schema.name="domoticz" \
      org.label-schema.description="Domoticz open source Home Automation system" \
      org.label-schema.license="GPLv3" \
      org.label-schema.docker.cmd="docker run -v ./config:/config -v ./plugins:/home/domoticz/plugins -e DATABASE_PATH=/config/domoticz.db -p 8086:8080 -d domoticz/domoticz" \
      maintainer="Domoticz Docker Maintainers <info@domoticz.com>"

WORKDIR /home/domoticz

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        tzdata \
        unzip \
        git \
        libudev-dev \
        libusb-0.1-4 \
        libsqlite3-0 \
        curl libcurl4-gnutls-dev \
        python3.9 \
        libpython3.9-dev \
        python3 \
        python3-pip \
    && OS="$(uname -s | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')" \
    && MACH=$(uname -m) \
    && if [ ${MACH} = "armv6l" ]; then MACH = "armv7l"; fi \
    && archive_file="domoticz_${OS}_${MACH}.tgz" \
    && version_file="version_${OS}_${MACH}.h" \
    && history_file="history_${OS}_${MACH}.txt" \
    && if [ -z "$STABLE"]; then curl -k -L https://releases.domoticz.com/releases/beta/${archive_file} --output domoticz.tgz; else curl -k -L https://releases.domoticz.com/releases/release/${archive_file} --output domoticz.tgz; fi \
    && tar xfz domoticz.tgz \
    && rm domoticz.tgz \
    && mkdir -p /home/domoticz/userdata \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install  requests \
    && pip3 install fabric2 \
	&& pip3 install python-periphery \
	&& curl -fsSL https://deb.nodesource.com/setup_17.x | bash - \
	&& apt-get install -y nodejs
	&& npm install lgtv \
    && npm install superagent \
	&& cp node_modules/lgtv/index.js /home/domoticz/node_modules/lgtv

VOLUME /home/domoticz/userdata

EXPOSE 8080
EXPOSE 6144
EXPOSE 443

ENV LOG_PATH=
ENV DATABASE_PATH=
ENV WWW_PORT=8080
ENV SSL_PORT=443
ENV EXTRA_CMD_ARG=

# timezone env with default
ENV TZ=Europe/Paris

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/home/domoticz/domoticz"]


