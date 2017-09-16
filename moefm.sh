#!/bin/bash
#
# 萌否电台bash脚本客户端
# moe.fm bash script
#
# History:
#   2013/10/12  Mike Akiba
#   2015/3/3    Desmond Ding

BASE_URL='http://moe.fm/listen/playlist?api=json'
API_KEY='&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8'
URL=$BASE_URL

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

    if [ -n "$ALBUM_ARG" ]; then
	URL+="&music=$ALBUM_ARG"
    fi

    if [ -n "$SONG_ARG" ]; then
	URL+="&song=$SONG_ARG"
    fi

    if [ -n "$RADIO_ARG" ]; then
	URL+="&radio=$RADIO_ARG"
    fi

    URL+=$API_KEY

    moefm_json=$(curl -s -A moefm.sh echo $URL)
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
    local param=$*
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


while getopts "a:s:r:h" arg
do
    case $arg in

	a)
	    ALBUM_ARG=$OPTARG;;

	s)
	    SONG_ARG=$OPTARG;;

	r)
	    RADIO_ARG=$OPTARG;;
	h)
	    echo -e "usage: moefm.sh [option(s)]\n
-a <ALBUM_ID> Specific album
-s <SONG_ID>  Specific song
-r <RADIO_ID> Specific personal radio
-h            Show this help page"
	    exit 1;;


	?)
	    echo "unknown arg";;

    esac
done





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

