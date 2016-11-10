#!/usr/bin/env bash
#安装cluster后 在中控机上安装redis-trib负责初始化

yum install -y python-pip
sudo pip install --upgrade pip
pip install redis-trib
