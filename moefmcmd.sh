#!/bin/bash
# 脚本名:
#   萌否电台客户端bash脚本
# 依赖软件:
#   mpg123, jq, curl
# 历史:
#   2013/10/12  Mike Akiba  初次发布

BASE_URL='http://moe.fm/listen/playlist?api=json&api_key='
API_KEY='4e229396346768a0c4ee2462d76eb0be052592bf8'
URL=$BASE_URL$API_KEY

# 检查歌曲信息是否为空，若为空则以“未知”替代
check_empty()
{
    local param=$1
    local empty="未知"

    if [ -z "$param" ]; then
        param=$empty
    fi

    echo "$param"
}

while true; do
    moefm_json=$(curl -s -A moefmcmd.sh echo $URL)
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
        mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].url")

        if [ "$mp3_url" == "null" ]; then
            echo "url为null"
            continue
        fi

        title=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].sub_title")
        artist=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].artist")
        album=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].wiki_title")
        
        clear

        title=$(check_empty $title)
        artist=$(check_empty $artist)
        album=$(check_empty $album)

        printf '曲名:   %s\n' "$title"
        printf '专辑:   %s\n' "$album"
        printf '艺术家: %s\n' "$artist"
        printf '\n'
        printf '[SPACE] 暂停/继续 [q] 下一曲 [Ctrl-Z] 退出\n'
        
        mpg123 -q -C "$mp3_url"
    done
done

