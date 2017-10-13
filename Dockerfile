FROM ubuntu:16.04
MAINTAINER Péter Nagy <nagylakas@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN rm -f /etc/localtime \
 && ln -s /usr/share/zoneinfo/Europe/Budapest /etc/localtime \
 && echo "Europe/Budapest" > /etc/timezone \
 && apt-get update \
 && apt-get -y dist-upgrade

RUN apt-get update \
 && apt-get upgrade \
 && apt-get -y install curl locales \
    apache2 php libapache2-mod-php xapian-tools \
    libpython2.7 python python-flask python-sleekxmpp python-xapian libical1a \
    bash-completion mktemp gawk w3m xsltproc poppler-utils unzip catdoc \
    libboost-filesystem1.58.0 libboost-system1.58.0 libtcmalloc-minimal4 libmysqlclient20 \
    libdigest-hmac-perl libfile-copy-recursive-perl \
    libunicode-string-perl libreadonly-perl \
    libio-tee-perl libmail-imapclient-perl libcurl3 \
    gnutls-bin language-pack-en language-pack-hu \
    supervisor openssh-server php-enchant php-xml \
    php-gettext php-zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY kopano-init.sh /usr/local/bin/
COPY kopano-start.sh /usr/local/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /tmp

ENV LANG="C"
ENV KOPANOVER="8.4.90.34_0+14-Ubuntu_16.04-amd64"

RUN curl -L https://download.kopano.io/community/core:/core-${KOPANOVER}.tar.gz | tar xzv 
RUN cd core-$KOPANOVER \
    && ls -1 *.deb | egrep -v '(-dev_|-dbg_|-doc_)' | xargs dpkg -i \
    && cd - \
    && rm -rf core-$KOPANOVER


ENV KOPANO_WEBAPPVERSION="3.4.0.770_0+519-Ubuntu_16.04-all"
RUN curl -L https://download.kopano.io/community/webapp:/webapp-$KOPANO_WEBAPPVERSION.tar.gz | tar xzv \
  && cd webapp-$KOPANO_WEBAPPVERSION \
  && dpkg -i *.deb \
  && cd - \
  && rm -rf webapp-$KOPANO_WEBAPPVERSION

RUN curl -L http://repo.z-hub.io/z-push:/final/Ubuntu_16.04/Release.key | apt-key add - \
 && echo "deb http://repo.z-hub.io/z-push:/final/Ubuntu_16.04/ /" > /etc/apt/sources.list.d/z-push.list \
 && apt-get update \
 && apt-get -y install z-push-kopano z-push-config-apache \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/bin/kopano-start.sh"]

