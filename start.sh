#!/bin/bash

function compareVersions
{
    VERSION=$1
    VERSION2=$2

    function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
    function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
    function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
    function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

    if version_gt $VERSION $VERSION2; then
        vcompare=1
    fi

    if version_le $VERSION $VERSION2; then
        vcompare=-1
    fi

    if version_lt $VERSION $VERSION2; then
        vcompare=-1
    fi

    if version_ge $VERSION $VERSION2; then
       vcompare=0
    fi
}

set -e

source /root/.phpbrew/bashrc
export PHPBREW_SET_PROMPT=1
export PHPBREW_RC_ENABLE=1

if [ ! -z "$PHP_VERSION" ]; then
    ACTIVE_PHP_VERSION=${PHP_VERSION}

    if [ ! -d /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION} ]; then
        phpbrew install php-${ACTIVE_PHP_VERSION} ${ACTIVE_PHP_VARIANTS}
    fi
fi

phpbrew switch ${ACTIVE_PHP_VERSION}

##
# Version check and different handling
##
compareVersions ${ACTIVE_PHP_VERSION} "7.0.0"
if [ 1 == $vcompare ] || [ 0 == $vcompare ]; then
    # Bigger or like 7.0.0
    sed -i -e 's~/root/.phpbrew/php/php-'${ACTIVE_PHP_VERSION}'/var/run/php-fpm.sock~9000~g' /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/etc/php-fpm.d/www.conf
    sed -i -e 's~nobody~www-data~g' /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/etc/php-fpm.d/www.conf
else
    # Smaller version than 7.0.0
    sed -i -e 's~/root/.phpbrew/php/php-'${ACTIVE_PHP_VERSION}'/var/run/php-fpm.sock~9000~g' /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/etc/php-fpm.conf
    sed -i -e 's~nobody~www-data~g' /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/etc/php-fpm.conf
fi

phpbrew fpm start

php -v

ps aux

netstat -an | grep 9000

#tail -f /dev/null
tail -f /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/var/log/php-fpm.log
