FROM alpine:3.15 AS builder

ENV TOR_VERSION="11.0.4"
ENV TOR_FINGERPRINT="0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
ENV TOR_TARBALL="tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz"

# build deps
RUN apk add --no-cache \
    ca-certificates \
    curl \
    gnupg \
    gpg \
    xz

WORKDIR /app

RUN curl -sLO "https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/${TOR_TARBALL}"
RUN curl -sLO "https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/${TOR_TARBALL}.asc"

# import tor key and verify downloaded tar
RUN gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
RUN gpg --output ./tor.keyring --export "${TOR_FINGERPRINT}"
RUN gpgv --keyring ./tor.keyring "./${TOR_TARBALL}.asc" "./${TOR_TARBALL}"

# extract tor
RUN tar --strip 1 -xvJf  "./${TOR_TARBALL}"

# rm junk
RUN rm "./${TOR_TARBALL}" "./${TOR_TARBALL}.asc" "tor.keyring"
RUN rm /app/Browser/fonts/Noto*

FROM frolvlad/alpine-glibc:alpine-3.15

# runtime deps
RUN apk update && \
    apk add \
        dbus-glib \
        gtk+3.0 \
        libxt \
        bash

# create tor user
ARG USER=tor
ARG HOME=/"$USER"

WORKDIR $HOME

RUN addgroup -S "$USER"
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$HOME" \
    --ingroup "$USER" \
    --no-create-home \
    "$USER"
    
COPY --chown="$USER":"$USER" --from=builder /app "$HOME"
USER tor

ENTRYPOINT ["/bin/bash"]
CMD ["/tor/Browser/start-tor-browser", "--log", "/dev/stdout"]
