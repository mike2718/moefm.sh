#!/bin/bash
# 程序:
#     萌否电台客户端bash脚本
# 依赖软件:
#     mpg123, jq, curl
# 历史:
# 2013/10/12	Mike Akiba	First release

for (( ; ; ))
do
    number=$(curl -s -A moefmcmd.sh 'http://www.random.org/integers/?num=1&min=1&max=9&col=1&base=10&format=plain&rnd=new')
   # echo $number # 物理随机数起作用？
    moefoufm_json=$(curl -s -A moefmcmd.sh 'http://moe.fm/listen/playlist?api=json&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8')
    mp3_url=$(echo $moefoufm_json | jq ".response.playlist[$number].url" | sed  's/\"//g')

    title=$(echo $moefoufm_json | jq ".response.playlist[$number].sub_title" | sed 's/\"//g')
    echo " $title"
    mpg123 -y -q $mp3_url 2>/dev/null
done

