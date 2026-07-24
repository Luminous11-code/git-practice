#!/bin/bash

for i in projectA projectB projectC;do
	if [ -d /home/ubuntu/git-practice/$i ];then
		echo "目录已存在"
	else
		mkdir /home/ubuntu/git-practice/$i
	fi

	touch /home/ubuntu/git-practice/$i/a.txt 
	echo "Hello" > /home/ubuntu/git-practice/$i/a.txt
done
