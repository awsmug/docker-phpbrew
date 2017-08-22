FROM centos:centos7
MAINTAINER Sven Wagener <sven@awesome.ug>

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
    net-tools \
    php56w

#Installing phpbrew
RUN curl -Lo /usr/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew && \
    chmod +x /usr/bin/phpbrew && \
    echo "[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc" >> ~/.bashrc && \
    echo "source /root/.phpbrew/bashrc" >> ~/.bashrc && \
    echo "export PHPBREW_SET_PROMPT=1" >> ~/.bashrc && \
    echo "export PHPBREW_RC_ENABLE=1" >> ~/.bashrc && \
    mkdir -p /usr/local/phpbrew && \
    phpbrew init --root=/usr/local/phpbrew

RUN phpbrew install 7.0.22 +fpm +cgi +mysql

RUN sed -i -e 's~/root/.phpbrew/php/php-7.0.22/var/run/php-fpm.sock~9000~g' /root/.phpbrew/php/php-7.0.22/etc/php-fpm.d/www.conf
RUN sed -i -e 's~nobody~www-data~g' /root/.phpbrew/php/php-7.0.22/etc/php-fpm.d/www.conf

RUN groupadd -g 82 www-data
RUN adduser -g www-data www-data

ADD run.sh /usr/bin/runphp
RUN chmod +x /usr/bin/runphp

EXPOSE 9000

ENTRYPOINT /usr/bin/runphp