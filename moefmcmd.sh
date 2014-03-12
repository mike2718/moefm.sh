#!/bin/bash
# 脚本名:
#   萌否电台客户端bash脚本
# 依赖软件:
#   mpg123, jq, curl
# 历史:
#   2013/10/12  Mike Akiba  初次发布

get_moefm_json () {
    curl -s -A moefmcmd.sh 'http://moe.fm/listen/playlist?api=json&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8'
    return
}

while true; do
    #number=$(curl -s -A moefmcmd.sh 'http://www.random.org/integers/?num=1&min=1&max=9&col=1&base=10&format=plain&rnd=new')
    a=( {0..8} )
    # Fisher-Yates shuffle 算法
    for i in {8..1}
    do
        rand_dev=$(od -An -N2 -i /dev/urandom | tr -d ' ')
        j=$((rand_dev % (i+1)))
        tmp=${a[$j]}
        a[$j]=${a[$i]}
        a[$i]=$tmp
    done
    for i in {0..8}
    do
        mp3_url=$(get_moefm_json | jq -M -r ".response.playlist[${a[$i]}].url")
        if [ "$mp3_url" == "null" ]; then
            continue
        fi
        title=$(get_moefm_json | jq -M -r ".response.playlist[${a[$i]}].sub_title")
        artist=$(get_moefm_json | jq -M -r ".response.playlist[${a[$i]}].artist")
        album=$(get_moefm_json | jq -M -r ".response.playlist[${a[$i]}].wiki_title")
        clear
        printf '艺术家: %s\n曲名:   %s\n专辑:   %s\n\n[SPACE] 暂停/继续 [q] 下一曲 [Ctrl-Z] 退出\n' "$artist" "$title" "$album"
        mpg123 -q -C "$mp3_url"
    done
done

