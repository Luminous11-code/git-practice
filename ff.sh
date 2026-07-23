#!/bin/bash

for u in projectA projectB projectC;do
	if [ -d /home/ubuntu/git-practice/$u ];then
		echo "目录已存在"
	else
		mkdir /home/ubuntu/git-practice/$u 
	fi

	       touch "$u/a.txt"
	        echo "Hello"  >  /home/ubuntu/git-practice/$u/a.txt
done
