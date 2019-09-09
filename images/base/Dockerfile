FROM debian:stretch

# grab gosu for easy step-down from root (https://github.com/tianon/gosu/releases)
ENV GOSU_VERSION 1.11

ENV LANG="C.UTF-8"

RUN set -ex; \
	\
  echo "===> Updating debian"; \
	apt-get update \
  ; \
  echo "===> Installing curl wget gpg"; \
	apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    gpg \
		wget \
	; \
  echo "===> Installing gosu"; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
  mkdir ~/.gnupg; \
  echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	\
  echo "===> Installing python and python packages"; \
  apt-get install -y --no-install-recommends \
    python3 \
  ; \
  curl -fSL "https://bootstrap.pypa.io/get-pip.py" | python3; \
  pip install jinja2 jinja2-cli \
  ; \
  apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*; \
 	rm -rf /var/lib/apt/lists/*;
