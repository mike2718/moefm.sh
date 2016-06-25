#!/bin/bash
#
# 萌否电台客户端bash脚本
# moe.fm bash script
#
# History:
#   2013/10/12  Mike Akiba
#   2015/3/3    Desmond Ding

BASE_URL='http://moe.fm/listen/playlist?api=json&api_key='
API_KEY='4e229396346768a0c4ee2462d76eb0be052592bf8'
URL=$BASE_URL$API_KEY

blue=`tput setaf 4`
reset=`tput sgr0`
bold=`tput bold`

TITLE="曲名:   ${bold}${blue}%s\n${reset}"
ALBUM="专辑:   ${bold}${blue}%s\n${reset}"
ARTIST="艺术家: ${bold}${blue}%s\n\n${reset}"
CONTROLLER="${bold}${blue}[SPACE]${reset} 暂停/继续 ${bold}${blue}[q]${reset} 下一曲 ${bold}${blue}[Ctrl-Z]${reset} 退出\n"
UI=$TITLE$ALBUM$ARTIST$CONTROLLER

get_json()
{
    moefm_json=$(curl -s -A moefmcmd.sh echo $URL)
}

# Fisher-Yates shuffle
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

get_mp3_url()
{
    mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].url")

    if [ "$mp3_url" == "null" ]; then
        echo "url为null"
        continue
    fi
}

get_song_title()
{
    title=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].sub_title")
    title=$(check_empty $title)
}

get_album_title()
{
    album=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].wiki_title")
    album=$(check_empty $album)
}

get_artist_name()
{
    artist=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].artist")
    artist=$(check_empty $artist)
}

get_album_cover()
{
    cover=$(echo $moefm_json | jq -M -r ".response.playlist[${a[$i]}].cover.small")
}


# 检查歌曲信息是否为空，若为空则以“未知”替代
# If the song info is empty, replace it with "Unknown"
check_empty()
{
    local param=$1
    local empty="未知"

    if [ -z "$param" ]; then
        param=$empty
    fi

    echo "$param"
}

# Show user interface
show_ui()
{
    printf "$UI" "$title" "$album" "$artist"
}

while true; do
    get_json

    shuffle

    for i in {0..8}
    do
        # Clean up previous song info
        clear

        # Get song info
        get_mp3_url
        get_song_title
        get_album_title
        get_artist_name

        show_ui

        # Play!
        mpg123 -q -C "$mp3_url"
    done
done

