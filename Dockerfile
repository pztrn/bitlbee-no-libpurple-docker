FROM alpine:latest

ENV BITLBEE_COMMIT=3a547ee9dcf5c790f68ee2118389dd27ed471b23 \
    RUNTIME_DEPS=" \
    cyrus-sasl \
    cyrus-sasl-crammd5 \
    cyrus-sasl-digestmd5 \
    cyrus-sasl-scram \
    cyrus-sasl-plain \
    glib \
    gnutls \
    json-glib \
    libevent \
    libgcrypt \
    libotr \
    libsasl"

# bitlbee
RUN apk add --update --no-cache --virtual build-dependencies \
    build-base \
    git \
    glib-dev \
    gnutls-dev \
    libevent-dev \
    libgcrypt-dev \
    libotr-dev \
    python3 ; \
    apk add --no-cache --virtual runtime-dependencies ${RUNTIME_DEPS}; \
    cd /root; \
    git clone -n https://github.com/bitlbee/bitlbee; \
    cd bitlbee; \
    git checkout ${BITLBEE_COMMIT}; \
    cp bitlbee.conf /bitlbee.conf; \
    mkdir /bitlbee-data; \
    ./configure --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl --events=libevent --otr=plugin --ssl=gnutls --config=/bitlbee-data; \
    make; \
    make install install-bin install-etc install-plugin-otr; \
    adduser -u 1000 -S bitlbee; \
    addgroup -g 1000 -S bitlbee; \
    chown -R bitlbee:bitlbee /bitlbee-data; \
    touch /var/run/bitlbee.pid; \
    chown bitlbee:bitlbee /var/run/bitlbee.pid; \
    rm -rf /root; \
    mkdir /root; \
    apk del --purge build-dependencies

# Install runtime dependencies
RUN apk add --no-cache ${RUNTIME_DEPS}

EXPOSE 6667
VOLUME /bitlbee-data

USER bitlbee
ENTRYPOINT ["/usr/local/sbin/bitlbee", "-F", "-n", "-d", "/bitlbee-data", "-c", "/bitlbee.conf"]
