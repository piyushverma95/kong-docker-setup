FROM ubuntu:xenial
LABEL maintainer="Kong Core Team <team-core@konghq.com>"

ENV KONG_VERSION 2.0.1

RUN useradd kong \
    && mkdir -p "/usr/local/kong" \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl perl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSLo kong.deb https://bintray.com/kong/kong-deb/download_file?file_path=kong-${KONG_VERSION}.xenial.$(dpkg --print-architecture).deb \
    && apt-get purge -y --auto-remove ca-certificates curl \
    && dpkg -i kong.deb \
    && rm -rf kong.deb

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

COPY ./http-log-extended /usr/local/share/lua/5.1/kong/plugins/http-log-extended

COPY ./fortress-http-log /usr/local/share/lua/5.1/kong/plugins/fortress-http-log

COPY ./kong.conf /etc/kong/kong.conf

COPY ./kong-2.0.1-0.rockspec /usr/local/lib/luarocks/rocks-5.1/2.0.1-0/kong-2.0.1-0.rockspec

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

CMD ["kong", "docker-start"]
