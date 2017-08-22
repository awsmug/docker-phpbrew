#!/bin/bash

set -e

source /root/.phpbrew/bashrc
export PHPBREW_SET_PROMPT=1
export PHPBREW_RC_ENABLE=1

phpbrew switch 7.0.22
phpbrew fpm start

php -v

ps aux

netstat -an | grep 9000

tail -f /root/.phpbrew/php/php-7.0.22/var/log/php-fpm.log
