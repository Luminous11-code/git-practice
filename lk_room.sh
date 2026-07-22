#!/bin/bash

a=$(ip addr show| grep "192" | awk ' {print $2} ')
b=$(top -bn1 | grep "Cpu(s)" | awk ' {print 100 - $8 "%"} ')
c=$(free -h | awk '/^内存/ {print $3/$2 * 100 "%"} ')
d=$(df -h / | tail -1 | awk ' {print $5} ')

echo "当前系统ip地址为：$a"
echo "Cpu使用率为：$b"
echo "内存使用率为：$c"
echo "磁盘空间使用率：$d"
