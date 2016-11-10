#!/usr/bin/env bash
yum install -y redis
sudo useradd redis -s /sbin/nologin
mkdir /data/redis && chown -R redis:redis /data/redis
mkdir -p /etc/redis/auto
cd /etc/redis
wget https://github.com/xiaomatech/redis/archive/master.zip -O conf.zip
unzip conf.zip
cp redis-cluster.sh /etc/init.d/redis-cluster && chmod a+x /etc/init.d/redis-cluster
chown -R redis:redis /etc/redis /data/redis /var/run/redis
mkdir -p /data/logs && chmod 777 -R /data/logs
sudo -u redis /etc/init.d/redis-cluster start
