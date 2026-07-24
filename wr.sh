#!/bin/bash

u=$(last && sudo lastb)
echo "$u" | while read a;do
	echo "当前用户登录记录：$a" >> /home/ubuntu/git-practice/c.txt
done 
