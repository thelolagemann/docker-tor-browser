# docker-tor-browser

A small docker container for running [Tor Browser](https://www.torproject.org/).

## Usage

**Docker run**
```shell
docker run --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=unix$DISPLAY \
  thelolagemann/tor-browser:latest
```

**Docker Compose**

```yaml
version: "3.9"

services:
  tor-browser:
    container_name: tor-browser
    image: thelolagemann/tor-browser:latest
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix
    environment:
      - DISPLAY=unix$DISPLAY
```

### X11 (Forwarding?)

Rather than using X11-Forwarding over SSH, this container relies on the host's X11 socket to be mounted directly into 
the container, as you can see in the examples above, this is as straightforward as mounting a volume with docker, and 
passing in the display environment variable to output to. 