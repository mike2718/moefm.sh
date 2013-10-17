#!/bin/bash
# 程序:
#     萌否电台客户端shell脚本
# 依赖软件:
#     mpg123, jq, curl
# 历史:
# 2013/10/12	Mike Akiba	初次发布

get_moefm_json () {
    curl -s -A moefmcmd.sh 'http://moe.fm/listen/playlist?api=json&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8'
    return
}

while true; do
    number=$(curl -s -A moefmcmd.sh 'http://www.random.org/integers/?num=1&min=1&max=9&col=1&base=10&format=plain&rnd=new')
    
    mp3_url=$(get_moefm_json | jq ".response.playlist[$number].url" | sed  's/\"//g')
    title=$(get_moefm_json | jq ".response.playlist[$number].sub_title" | sed 's/\"//g')
    clear
    echo "
* $title
-------------------------------------------------------------------
[SPACE] 暂停/继续 [q] 下一曲 [Ctrl-Z] 退出
"
    mpg123 -q -C $mp3_url
done

