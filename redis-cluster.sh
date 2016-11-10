#!/usr/bin/env bash
#
# chkconfig:   - 86 16

PORT=(6376 6377 6378 6379 6380 6381 6382 6383)
if [[ `ifconfig eth0 >/dev/null 2>&1 && echo ok` ]]; then
    LOCALIP=$(ifconfig eth0 |grep "inet addr" |awk '{print $2}' |awk -F':' '{print $2}')
else
    LOCALIP=$(ifconfig |grep -oE "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |grep -vE "127.*|255.*")
fi

USAGE="\
Usage: redis-cluster <command> [options]
  stop                   停止集群
  start                  启动集群
  restart                重启集群
  clear                  集群所有节点清档
  status                 查看集群状态
  info [参数]            查看info信息
  config [参数][参数]    设置及查看config信息
  help                   查看帮助
Examples:
  redis-cluster info keyspace                   查看keys量
  redis-cluster config get maxclients           查看连接数上限
  redis-cluster config set maxclients 10000     修改连接数
"


case "$1" in
    stop)
        for port in ${PORT[*]}; do {
            redis-cli -p $port shutdown
        } & done
        echo -e "Stopping Redis-Cluster:\t\t\t\t\t[  \033[32mOK\033[0m  ]"
        ;;
    start)
        for port in ${PORT[*]}; do {
            redis-server /etc/redis/instances/$port.conf
        } & done
        echo -e "Starting Redis-Cluster:\t\t\t\t\t[  \033[32mOK\033[0m  ]"
        ;;
    clear)
        read -p "Do you know what you are doing?[y/n]:" select
        if [[ $select == "y" ]] || [[ $select == "yes" ]]; then
            MPORT=$(redis-cli -p ${PORT[2]} cluster nodes |grep master |awk '{print $2}' |awk -F':' '{print $2}')
            if [[ $MPORT == "" ]]; then
                echo "Redis cluster no running."
                break
            fi
            for port in $MPORT; do {
                redis-cli -p $port flushall >/dev/null 2>&1
                echo $port
            } done
            echo "Redis cluster clear files success."
            #$0 info keyspace
        else
            echo "Bye!"
        fi
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        redis-trib.py check $LOCALIP:${PORT[2]}
        ;;
    info)
        MPORT=$(redis-cli -p ${PORT[2]} cluster nodes |grep master |awk '{print $2}' |awk -F':' '{print $2}')
        for port in $MPORT; do {
            echo -e "# \033[1m\033[32m$LOCALIP:$port\033[0m"
            redis-cli -p $port info $2
            echo
        } done
        ;;
    config)
        MPORT=$(redis-cli -p ${PORT[2]} cluster nodes |grep master |awk '{print $2}' |awk -F':' '{print $2}')
        for port in $MPORT; do {
            echo -e "# \033[1m\033[32m$LOCALIP:$port\033[0m"
            redis-cli -p $port config $2 $3 $4
            echo
        } done
        ;;
    help)
        echo "$USAGE"
        ;;
    *)
        echo "$USAGE"
        exit 2
esac
