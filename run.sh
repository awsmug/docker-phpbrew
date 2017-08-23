#!/bin/bash

set -e

source /root/.phpbrew/bashrc
export PHPBREW_SET_PROMPT=1
export PHPBREW_RC_ENABLE=1

sed -i -e 's~/root/.phpbrew/php/php-'${ACTIVE_PHP_VERSION}'/var/run/php-fpm.sock~9000~g' /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/etc/php-fpm.d/www.conf
sed -i -e 's~nobody~www-data~g' /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/etc/php-fpm.d/www.conf

/bin/bash

phpbrew switch ${ACTIVE_PHP_VERSION}
phpbrew fpm start

php -v

ps aux

netstat -an | grep 9000

tail -f /root/.phpbrew/php/php-${ACTIVE_PHP_VERSION}/var/log/php-fpm.log
