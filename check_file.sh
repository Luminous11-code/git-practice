#!/bin/bash
if [ -f "$1" ]; then
	    echo "✅ 文件 $1 存在"
else
	        echo "❌ 文件 $1 不存在"
fi
