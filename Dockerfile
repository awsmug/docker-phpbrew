FROM centos:centos7

ENV ACTIVE_PHP_VERSION=7.1.8
ENV ACTIVE_PHP_VARIANTS="+fpm +mysql +calendar +dom +bcmath +bz2 +debug +gd +json +phar +session +zip +xml +xml_all +zlib"

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# Install required PHP packages
RUN yum update && yum -y install \
    supervisor \
    make \
    curl \
    gcc \
    wget \
    lbzip2 \
    libxml2-devel \
    openssl-devel \
    bzip2-devel \
    readline-devel \
    libxslt-devel \
    lcov \
    systemtap-sdt-devel \
    net-tools \
    php56w

#Installing phpbrew
RUN curl -Lo /usr/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew && \
    chmod +x /usr/bin/phpbrew && \
    mkdir -p /usr/local/phpbrew && \
    phpbrew init --root=/usr/local/phpbrew

RUN  phpbrew install php-7.1.8 ${ACTIVE_PHP_VARIANTS} && \
     phpbrew install php-7.0.22 ${ACTIVE_PHP_VARIANTS} && \
     phpbrew install php-5.6.31 ${ACTIVE_PHP_VARIANTS}

ADD run.sh /usr/bin/start

RUN source /root/.phpbrew/bashrc && \
    echo "[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc" >> ~/.bashrc && \
    export PHPBREW_SET_PROMPT=1 && \
    export PHPBREW_RC_ENABLE=1 && \
    groupadd -g 82 www-data && \
    adduser -g www-data www-data && \
    chmod +x /usr/bin/start

RUN yum clean all

EXPOSE 9000

ENTRYPOINT start