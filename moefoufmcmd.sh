#!/bin/bash
# Program:
#     萌否电台客户端bash脚本
# History:
# 2013/10/12	Mike	First release

for (( ; ; ))
do
mp3_url=$(curl 'http://moe.fm/listen/playlist?api=json&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8' | jq '.response.playlist[0].url' | sed  's/\"//g' )

mpg321 $mp3_url
done

