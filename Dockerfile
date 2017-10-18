FROM ubuntu:16.04
MAINTAINER Péter Nagy <nagylakas@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG="C"

RUN rm -f /etc/localtime \
 && ln -s /usr/share/zoneinfo/Europe/Budapest /etc/localtime \
 && echo "Europe/Budapest" > /etc/timezone \
 && apt-get update \
 && apt-get -y dist-upgrade \
 && apt-get install -y curl lynx apt-utils \
 && rm -rf /var/cache/apt /var/lib/apt/lists

RUN mkdir -p /tmp/repo
WORKDIR /tmp/repo

RUN curl -L `lynx -listonly -nonumbers -dump https://download.kopano.io/community/core:/ | grep Ubuntu_16.04-amd64.tar.gz` | tar -xz --strip-components 1 -f -
RUN curl -L `lynx -listonly -nonumbers -dump https://download.kopano.io/community/webapp:/ | grep Ubuntu_16.04-all.tar.gz` | tar -xz --strip-components 1 -f -

RUN apt-ftparchive packages . | gzip -9c > Packages.gz && echo "deb file:/tmp/repo ./" > /etc/apt/sources.list.d/kopano.list
RUN apt-get update \
 && apt-get install -y --allow-unauthenticated \
 kopano-server-packages \
 kopano-webapp \
 kopano-webapp-plugin-titlecounter \
 && rm -rf /var/cache/apt /var/lib/apt/lists

RUN curl -L http://repo.z-hub.io/z-push:/final/Ubuntu_16.04/Release.key | apt-key add - \
 && echo "deb http://repo.z-hub.io/z-push:/final/Ubuntu_16.04/ /" > /etc/apt/sources.list.d/z-push.list \
 && apt-get update \
 && apt-get -y install z-push-kopano z-push-config-apache \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY kopano-init.sh /usr/local/bin/
COPY kopano-start.sh /usr/local/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/local/bin/kopano-start.sh"]

