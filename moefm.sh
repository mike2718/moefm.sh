#!/bin/bash
#
# 萌否电台bash脚本客户端
# moe.fm bash script
#
# History:
#   2013/10/12  Mike Akiba
#   2015/3/3    Desmond Ding

BASE_URL='http://moe.fm/listen/playlist?api=json'
SEARCH_URL='http://api.moefou.org/search/sub.json?sub_type=song'
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


search()
{

    local keywd=$*
    SEARCH_URL+="&keyword="
    SEARCH_URL+=$keywd
    SEARCH_URL+=$API_KEY
    search_json=$(curl -s -A moefm.sh echo $SEARCH_URL)

    SEARCH_ENTRIES=$(echo $search_json | jq -M -r ".response.information.count")

    song_list=( {0..100} )
    for((i=0;i<SEARCH_ENTRIES;i++))
    do
	song_list[$i]=$(echo $search_json | jq -M -r ".response.subs[$i].sub_id")

    done

    TITLE_LIST=( {0..100} )
    ALBUM_LIST=( {0..100} )
    ARTIST_LIST=( {0..100} )
    MUSIC_LIST=( {0..100} )
    QUERY_OK=( {0..100} )
}

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
    ITEMS=$(echo $moefm_json | jq -M -r ".response.information.item_count")


}

# Fisher-Yates shuffle
shuffle()
{
    a=( {0..100} )
    # set 'a' with a big constant..

    for((i=$ITEMS -1;i>0;i--))
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
    local arg=$*
    mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[$arg].url")

    if [ "$mp3_url" == "null" ]; then
        echo "url为null"
        continue
    fi
}

get_song_title()
{
    local arg=$*
    title=$(echo $moefm_json | jq -M -r ".response.playlist[$arg].sub_title")
    title=$(check_empty $title)
}

get_album_title()
{
    local arg=$*
    album=$(echo $moefm_json | jq -M -r ".response.playlist[$arg].wiki_title")
    album=$(check_empty $album)
}

get_artist_name()
{
    local arg=$*
    artist=$(echo $moefm_json | jq -M -r ".response.playlist[$arg].artist")
    artist=$(check_empty $artist)
}

get_album_cover()
{
    local arg=$*
    cover=$(echo $moefm_json | jq -M -r ".response.playlist[$arg].cover.small")
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



Rebuild_show_ui()
{
    local arg=$*
    printf "$UI" "${TITLE_LIST[$arg]}" "${ALBUM_LIST[$arg]}" "${ARTIST_LIST[$arg]}"
}








while getopts "a:s:S:r:Rh" arg
do
    case $arg in

	a)
	    ALBUM_ARG=$OPTARG;;

	s)
	    SONG_ARG=$OPTARG;;

	S)
	    KEYWORDS=$OPTARG
	    SEAR_OPT=1;;

	r)
	    RADIO_ARG=$OPTARG;;

	R)
	    SHUF_OPT=1;;

	h)
	    echo -e "usage: moefm.sh [option(s)]\n
-a <ALBUM_ID> Specific album
-h            Show this help page
-r <RADIO_ID> Specific personal radio
-R            Shuffle (Random)
-s <SONG_ID>  Specific song
-S <SONG_NAME> Search a song
"
	    exit 1;;


	?)
	    echo "unknown arg";;

    esac
done




while true; do

    get_json

    for((i=0;i<$ITEMS;i++))
    do
	a[$i]=$i
    done
    # if not shuffle, we should prompt ordered playlist


    if [ -n "$SHUF_OPT" ]; then
	shuffle
    fi


    if [ -n "$SEAR_OPT" ]; then

	KEYWORDS=${KEYWORDS//' '/'%20'}
	# replace ' ' with '%20'

	search $KEYWORDS
	entrynumb=0
	for((i=0;i<$SEARCH_ENTRIES;i++))
	# Search results are sorted by song id (greater),
	# but we always upload main song at first...
	do

	    QUERY_OK[$i]=$(echo $search_json | jq -M -r ".response.subs[$i].sub_upload")
	    if [ "${QUERY_OK[$i]}" != "[]" ]; then
		clear
		# 'sub_upload == []'  means no mp3 file was uploaded
		entrynumb=entrynumb+1
		entry_json=$(curl -s -A moefm.sh echo "$BASE_URL&song=${song_list[$i]}$API_KEY")

		TITLE_LIST[$i]=$(echo $entry_json | jq -M -r ".response.playlist[0].sub_title")
		ALBUM_LIST[$i]=$(echo $entry_json | jq -M -r ".response.playlist[0].wiki_title")
		ARTIST_LIST[$i]=$(echo $entry_json | jq -M -r ".response.playlist[0].artist")
		MUSIC_LIST[$i]=$(echo $entry_json | jq -M -r ".response.playlist[0].url")
		
		TITLE_LIST[$i]=$(check_empty ${TITLE_LIST[$i]})
		ALBUM_LIST[$i]=$(check_empty ${ALBUM_LIST[$i]})
		ARTIST_LIST[$i]=$(check_empty ${ARTIST_LIST[$i]})


		Rebuild_show_ui $i
		mpg123 -q -C "${MUSIC_LIST[$i]}"
	    fi


	done

	if [ "$entrynumb" = "0" ] ; then
	    echo "There isn't any song..."
	    exit 0

	fi
    else

	for ((i=0;i<$ITEMS;i++))
	do
            # Clean up previous song info
	    clear
            # Get song info
            get_mp3_url ${a[$i]}
            get_song_title ${a[$i]}
            get_album_title ${a[$i]}
            get_artist_name ${a[$i]}

            show_ui

            # Play!
            mpg123 -q -C "$mp3_url"
	done
    fi
done

