#!/bin/bash
# php-fpm-wrapper need cause of https://groups.google.com/forum/#!topic/highload-php-en/VXDN8-Ox9-M
# This script is used to remove the wrapped logs from php-fpm
/usr/sbin/php-fpm7.2 -F -O 2>&1 | sed -u 's/.*WARNING: \[pool www\] child [0-9]* said into std[a-z]*: \"\(.*\)\"$/\1/'
