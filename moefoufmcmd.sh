#!/bin/bash
# Program:
#     萌否电台客户端bash脚本
# History:
# 2013/10/12	Mike	First release

for (( ; ; ))
do
    number=$(curl -s -A moefmcmd.sh 'http://www.random.org/integers/?num=1&min=1&max=9&col=1&base=10&format=plain&rnd=new')
   # echo $number # 物理随机数起作用？
    mp3_url=$(curl -s -A moefmcmd.sh 'http://moe.fm/listen/playlist?api=json&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8' | jq ".response.playlist[$number].url" | sed  's/\"//g' )
    mpg321 $mp3_url
done

