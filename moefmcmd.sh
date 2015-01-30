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

TITLE='曲名:   %s\n'
ALBUM='专辑:   %s\n'
ARTIST='艺术家: %s\n\n'
CONTROLLER='[SPACE] 暂停/继续 [q] 下一曲 [Ctrl-Z] 退出\n'
UI=$TITLE$ALBUM$ARTIST$CONTROLLER

# 获取json
get_json()
{
    moefm_json=$(curl -s -A moefmcmd.sh echo $URL)

}

# Fisher-Yates shuffle 算法
shuffle()
{
    a=( {0..8} )
    
    for i in {8..1}
    do
        rand_dev=$(od -An -N2 -i /dev/urandom | tr -d ' ')
        j=$((rand_dev % (i+1)))
        tmp=${a[$j]}
        a[$j]=${a[$i]}
        a[$i]=$tmp
    done
}

# 获取mp3地址
get_mp3_url()
{
    mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].url")

    if [ "$mp3_url" == "null" ]; then
        echo "url为null"
        continue
    fi
}

# 获取歌曲标题
get_title()
{
    title=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].sub_title")
    title=$(check_empty $title)
}

# 获取专辑
get_album()
{
    album=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].wiki_title")
    album=$(check_empty $album)
}

# 获取艺术家
get_artist()
{
    artist=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].artist")
    artist=$(check_empty $artist)
}


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

# 显示文字用户界面
show_ui()
{
    printf "$UI" "$title" "$album" "$artist"
}

while true; do
    # 获取json
    get_json
   
    # 随机歌曲
    shuffle

    for i in {0..8}
    do
        # 清除上一首歌曲信息
        clear

        # 获取歌曲信息
        get_mp3_url
        get_title
        get_album
        get_artist

        # 显示用户界面
        show_ui

        # 播放歌曲
        mpg123 -q -C "$mp3_url"
    done
done

