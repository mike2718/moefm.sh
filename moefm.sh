#!/bin/bash
#
# 萌否电台bash脚本客户端
# moe.fm bash script
#
# History:
#   2013/10/12  Mike Akiba
#   2015/3/3    Desmond Ding
#   2017/9/17   3usi9

# URL part
BASE_URL='http://moe.fm/listen/playlist?api=json'
SEARCH_URL='http://api.moefou.org/search/sub.json?sub_type=song'
API_KEY='&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8'
DATABASE_DIR=$MOEFM_DATABASE
DATABASE="$DATABASE_DIR"
DATABASE+="/database"
# UI part
black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`
bold=`tput bold`

COLOR_ARG=$blue


# Play Queue
playq_url=()
playq_tit=()
playq_alb=()
playq_art=()
playq_id=()
playq_size=()
cover_url=()

playq_back=0
playq_front=0

push_playq()
{
    playq_url[$playq_back]=$1
    playq_tit[$playq_back]=$2
    playq_alb[$playq_back]=$3
    playq_art[$playq_back]=$4
    playq_id[$playq_back]=$5
    playq_size[$playq_back]=$6
    cover_url[$playq_back]=$7
    playq_back=$(($playq_back+1))
}

pop_playq()
{
    playq_front=$(($playq_front+1))
}

change_playq_front()
{
    playq_url[$playq_front]=$1
    playq_tit[$playq_front]=$2
    playq_alb[$playq_front]=$3
    playq_art[$playq_front]=$4
    playq_id[$playq_front]=$5
    playq_size[$playq_front]=$6
    cover_url[$playq_back]=$7
}
# for dynamically resolving

check_que_empty()
{
    if [ "$playq_front" = "$playq_back" ]; then
	echo "1"
    else
	echo "0"
    fi
}

check_str_empty()
{
    local param=$*
    local str_empty="未知"

    if [ -z "$param" ]; then
        param=$str_empty
    fi

    echo "$param"
}

switch_net_to_save()
{
    local str=$*;
    str=${str//' '/'%20'};
    echo "$str"
}

switch_save_to_display()
{
    local str=$*;
    str=${str//'&#039;'/"'"}
    str=${str//'&#39;'/"'"}
    str=${str//'&lt;'/'<'}
    str=${str//'&gt;'/'>'}
    str=${str//'%20'/' '};
    echo "$str"
}

switch_display_to_save()
{
    local str=$*;
    str=${str//"'"/'&#039;'}
    str=${str//"<"/'&lt;'}
    str=${str//">"/'&gt;'}
    str=${str//" "/'%20'}
    echo "$str"
}

show_cover()
{

    local url=$*
    echo "HIT!"
    wget -O "$DATABASE_DIR/opt.jpg"  "$url"
    pos=$(xwininfo -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}') | grep "\-geometry" | awk '{print $2}')

    echo $pos

    wid=$(echo $pos | awk -F 'x' '{print $1}')
    res=$(echo $pos | awk -F 'x' '{print $2}')
    hei=$(echo $res | awk -F '+' '{print $1}')
    xcnt=$(echo $res | awk -F '+' '{print $2}')
    ycnt=$(echo $res | awk -F '+' '{print $3}')

    if [ "$ycnt" = "" ]; then
	ycnt="0"
    fi
    if [ "$xcnt" = "" ]; then
	xcnt="0"
    fi

    echo "xcnt:$xcnt ycnt:$ycnt wid=$wid  hei=$hei"

    nx=$(($wid))
    nx=$(($nx+$xcnt))
    ny=$(($hei*2))
    ny=$(($ny+$ycnt))

    pic=$(identify "$DATABASE_DIR/opt.jpg" | awk '{print $3}')
    echo "nx:$nx ny:$ny"

    px=$(echo $pic | awk -F 'x' '{print $1}')
    py=$(echo $pic | awk -F 'x' '{print $2}')

    echo "px=$px, py=$py"

    feh -g "$pic+$nx+$ny" -x "$DATABASE_DIR/opt.jpg"

}

love_track()
{
    local id=$*
    local url=$BASE_URL
    url+="&song=$id"
    url+=$API_KEY
    local moefm_json=$(curl -s -A moefm.sh echo $url)
    
    local mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[0].url")
    local title=$(echo $moefm_json | jq -M -r ".response.playlist[0].sub_title")
    local album=$(echo $moefm_json | jq -M -r ".response.playlist[0].wiki_title")
    local artist=$(echo $moefm_json | jq -M -r ".response.playlist[0].artist")
    local song_siz=$(echo $moefm_json | jq -M -r ".response.playlist[0].file_size")


    if [ "$title" = "" ]; then
	echo "输入好像哪里不对..."
	exit 0
    fi

    title=$(switch_net_to_save "$title")
    album=$(switch_net_to_save "$album")
    artist=$(switch_net_to_save "$artist")

    title=$(switch_save_to_display "$title")
    album=$(switch_save_to_display "$album")
    artist=$(switch_save_to_display "$artist")

    python3 -c 'import scrobble; scrobble.Love_one("'"$title"'", "'"$album"'", "'"$artist"'")' >/dev/null 2>&1
    echo -e "\e[1m\e[33m$title\e[0m - \e[1m\e[32m$artist\e[0m loved"


}

pure_download()
{
    clear
    local id=$*
    local url=$BASE_URL
    url+="&song=$id"
    url+=$API_KEY
    local moefm_json=$(curl -s -A moefm.sh echo $url)
    
    local mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[0].url")
    local title=$(echo $moefm_json | jq -M -r ".response.playlist[0].sub_title")
    local album=$(echo $moefm_json | jq -M -r ".response.playlist[0].wiki_title")
    local artist=$(echo $moefm_json | jq -M -r ".response.playlist[0].artist")
    local song_siz=$(echo $moefm_json | jq -M -r ".response.playlist[0].file_size")

    if [ "$title" = "" ]; then
	echo "输入好像哪里不对..."
	exit 0
    fi

    title=$(switch_net_to_save "$title")
    album=$(switch_net_to_save "$album")
    artist=$(switch_net_to_save "$artist")

    title=$(switch_save_to_display "$title")
    album=$(switch_save_to_display "$album")
    artist=$(switch_save_to_display "$artist")

    local path="$DATABASE_DIR"
    path+="/$id.mp3"
    title=$(check_str_empty $title)
    album=$(check_str_empty $album)
    artist=$(check_str_empty $artist)


    echo -e "正在下载的歌曲: "
    local TITLE="曲名:   ${bold}${COLOR_ARG}%s\n${reset}"
    local ALBUM="专辑:   ${bold}${COLOR_ARG}%s\n${reset}"
    local ARTIST="艺术家: ${bold}${COLOR_ARG}%s\n${reset}"
    local ID="歌曲ID: ${bold}${COLOR_ARG}%s\n\n${reset}"
    local UI=$TITLE$ALBUM$ARTIST$ID
    printf "$UI" "$title" "$album" "$artist" "$id"

    title=$(switch_display_to_save "$title")
    album=$(switch_display_to_save "$album")
    artist=$(switch_display_to_save "$artist")

    local vect="$id####$title####$album####$artist"
    local res=$(cat $DATABASE | grep "$id")

    if [ "$res" = "" ]; then
	### database didn't have this song...
	echo $vect >> $DATABASE
	wget "$mp3_url" -O "$path" --progress=bar:force 2>&1 | tail -f -n +8
	echo "下载完成！"
	# Add the entry
    else
	### Entry exists
	local file_size=$(du -a "$path" | awk '{print $1}')
	local delta=$(($file_size-$song_siz))
	delta=${delta#-}
	# There is always faults...

	if [ $delta -gt 10 ]; then
	    ### FILE_BROKEN!
	    rm "$path"
	    sed -i '/^'"$id"'/d' $DATABASE
	    # delete database entry
	    echo $vect >> $DATABASE
	    wget "$mp3_url" -O "$path" --progress=bar:force 2>&1 | tail -f -n +8
	    echo "下载完成！"
	else
	    echo "条目已存在！"
	fi
    fi

}


show_ui()
{
    TITLE="曲名:   ${bold}${COLOR_ARG}%s\n${reset}"
    ALBUM="专辑:   ${bold}${COLOR_ARG}%s\n${reset}"
    ARTIST="艺术家: ${bold}${COLOR_ARG}%s\n${reset}"
    ID="歌曲ID: ${bold}${COLOR_ARG}%s\n\n${reset}"
    CONTROLLER="${bold}${COLOR_ARG}[SPACE]${reset} 暂停/继续 ${bold}${COLOR_ARG}[q]${reset} 下一曲 ${bold}${COLOR_ARG}[Ctrl-Z]${reset} 退出\n"
    
    UI=$TITLE$ALBUM$ARTIST$ID$CONTROLLER

    printf "$UI" "$1" "$2" "$3" "$4"

    if [ "$COV_OPT" = "1" ]; then
	echo "cover_url=${cover_url[$playq_front]}"
	show_cover "${cover_url[$playq_front]}"
    fi
}



# # Fisher-Yates shuffle
# shuffle()
# {
#     a=( {0..100} )
#     # set 'a' with a big constant..

#     for((i=$ITEMS -1;i>0;i--))
#     do
#         rand_dev=$(od -An -N2 -i /dev/urandom | tr -d ' ')
#         j=$((rand_dev % (i+1)))
#         tmp=${a[$j]}
#         a[$j]=${a[$i]}
#         a[$i]=$tmp
#     done
# }

search_local()
{
    local keywd=$*
    keywd=$(switch_display_to_save "$keywd");
    # I have no choice...
    res=$(cat $DATABASE | grep -i "$keywd")

    for i in $(echo $res)
    do
	local sid=$(echo $i | awk -F '####' '{print $1}')
	local stit=$(echo $i | awk -F '####' '{print $2}')
	local salb=$(echo $i | awk -F '####' '{print $3}')
	local sart=$(echo $i | awk -F '####' '{print $4}')

	stit=$(check_str_empty $stit)
	salb=$(check_str_empty $salb)
	sart=$(check_str_empty $sart)

	push_playq "null" "$stit" "$salb" "$sart" "$sid" "null" "null"
    done
}

search()
{

    local keywd=$*
    keywd=${keywd//' '/'%20'}

    SEARCH_URL+="&keyword="
    SEARCH_URL+=$keywd
    SEARCH_URL+=$API_KEY

    search_json=$(curl -s -A moefm.sh echo $SEARCH_URL)
    search_entries=$(echo $search_json | jq -M -r ".response.information.count")

    for((i=0;i<search_entries;i++))
    do
	local query=$(echo $search_json | jq -M -r ".response.subs[$i].sub_upload")
	if [ "$query" != "[]" ]; then
	    # valid
	    local s_id=$(echo $search_json | jq -M -r ".response.subs[$i].sub_id")
	    local s_url=$BASE_URL
	    s_url+="&song=$s_id"
	    s_url+=$API_KEY
	    push_playq "$s_url" "to_be_resolved" "to_be_resolved" "to_be_resolved" "$s_id" "to_be_resolved" "to_be_resolved"
	    # dynamic resolve to lessen server burden
	fi
    done
    # push valid songs into play queue

}

require_list()
{
    local get_arg=$*
    # Use GET method

    local url=$BASE_URL
    url+="$get_arg"
    url+=$API_KEY
    local moefm_json=$(curl -s -A moefm.sh echo $url)
    local ITEMS=$(echo $moefm_json | jq -M -r ".response.information.item_count")
    for((i=0;i<ITEMS;i++))
    do
	local mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[$i].url")
	local title=$(echo $moefm_json | jq -M -r ".response.playlist[$i].sub_title")
	local album=$(echo $moefm_json | jq -M -r ".response.playlist[$i].wiki_title")
	local artist=$(echo $moefm_json | jq -M -r ".response.playlist[$i].artist")
	local song_id=$(echo $moefm_json | jq -M -r ".response.playlist[$i].sub_id")
	local song_siz=$(echo $moefm_json | jq -M -r ".response.playlist[$i].file_size")
	local song_cov=$(echo $moefm_json | jq -M -r ".response.playlist[$i].cover.large")
	# large okay?

	title=$(check_str_empty $title)
	album=$(check_str_empty $album)
	artist=$(check_str_empty $artist)

	push_playq "$mp3_url" "$title" "$album" "$artist" "$song_id" "$song_siz" "$song_cov"
    done
}


resolve_json()
{
    local url=$1
    local moefm_json=$(curl -s -A moefm.sh echo $url)
    local items=$(echo $moefm_json | jq -M -r ".response.information.item_count")
    
    for((i=0;i<$items;i++))
    do
	local mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[$i].url")
	# Add Search Functions...
	local title=$(echo $moefm_json | jq -M -r ".response.playlist[$i].sub_title")
	local album=$(echo $moefm_json | jq -M -r ".response.playlist[$i].wiki_title")
	local artist=$(echo $moefm_json | jq -M -r ".response.playlist[$i].artist")
	local id=$(echo $moefm_json | jq -M -r ".response.playlist[$i].sub_id")
	local size=$(echo $moefm_json | jq -M -r ".response.playlist[$i].file_size")
	local cov=$(echo $moefm_json | jq -M -r ".response.playlist[$i].cover.large")
	title=$(check_str_empty $title)
	album=$(check_str_empty $album)
	artist=$(check_str_empty $artist)

	change_playq_front "$mp3_url" "$title" "$album" "$artist" "$id" "$size" "$cov"
    done

}


# main function
while getopts "a:c:C:D:F:s:S:r:RhlLUXI" arg
do
    case $arg in
	a)
	    ALBUM_ARG=$OPTARG;;

	C)
	    tmp=$OPTARG
	    COLOR_ARG=`eval echo '$'"$tmp"`;;

	D)
	    ARG=$OPTARG
	    pure_download $ARG
	    exit 0;;

	F)
	    love_track $OPTARG
	    exit 0;;

	I)
	    COV_OPT=1;;

	l)
	    MIX_OPT=1;;

	L)
	    ABS_LOCAL=1;;

	r)
	    RADIO_ARG=$OPTARG;;

	R)
	    REPT_OPT=1;;

	s)
	    SONG_ARG=$OPTARG;;

	S)
	    KEYWORDS=$OPTARG
	    SEAR_OPT=1;;

	U)
	    SCRO_OPT=1;;
	
	X)
	    FREE_OPT=1;;

	h)
	    echo -e "usage: moefm.sh [option(s)]\n
-a <ALBUM_ID> Specific album
-C <COLOR>    Set UI Color
-D <SONG_ID>  Download a song
-F <SONG_ID>  Love a song
-h            Show this help page
-l            Mixed Mode (automatically download and save music)
-L            Local Mode (if there is no internet connection...)
-r <RADIO_ID> Specific personal radio
-R            Repeat Mode
-s <SONG_ID>  Specific song
-S <SONG_NAME> Search a song
-U            Upload with Last.fm (scrobble)
-X            Listen freely"
	    exit 1;;

	?)
	    echo "unknown arg";;

    esac
done





download()
{
    local path=$1
    local sid=${playq_id[$playq_front]}
    local stitle=${playq_tit[$playq_front]}
    local salbum=${playq_alb[$playq_front]}
    local sartist=${playq_art[$playq_front]}

    stitle=$(switch_net_to_save "$stitle")
    salbum=$(switch_net_to_save "$salbum")
    sartist=$(switch_net_to_save "$sartist")

    local vect="$sid####$stitle####$salbum####$sartist"

    local res=$(cat $DATABASE | grep "$sid")
    if [ "$res" = "" ]; then

	if [ "$MIX_OPT" = "1" ]; then
	  nohup wget -q "${playq_url[$playq_front]}" -O "$path" >/dev/null 2>&1 &
	    echo $vect >> $DATABASE
	fi
	echo "${playq_url[$playq_front]}"
	# return

    else
	local file_size=$(du -a "$path" | awk '{print $1}')
	local delta=$(($file_size-${playq_size[$playq_front]}))
	delta=${delta#-}
	# There is always faults...

	if [ $delta -lt 10 ]; then
	    echo "$path"
	else
	    rm "$path"
	    sed -i '/^'"$sid"'/d' $DATABASE
	    # delete database entry
	    if [ "$MIX_OPT" = "1" ]; then
		nohup wget -q "${playq_url[$playq_front]}" -O "$path" >/dev/null 2>&1 &
		echo $vect >> $DATABASE
	    fi

	    echo "${playq_url[$playq_front]}"

	fi

    fi
}



play() # Need to check empty before play
{
    local file_path="$DATABASE_DIR"
    file_path+="/${playq_id[$playq_front]}.mp3"
    if [ "$ABS_LOCAL" = "1" ]; then
 	mpg123 -q -C "$file_path" 
	
    else
	local final_path=$(download $file_path)
	mpg123 -q -C "$final_path"
    fi
}


play_a_song()
{

    if [ "${playq_tit[$playq_front]}" = "to_be_resolved" ]; then
	resolve_json "${playq_url[$playq_front]}"
    fi

    local sid=${playq_id[$playq_front]}
    local stitle=${playq_tit[$playq_front]}
    local salbum=${playq_alb[$playq_front]}
    local sartist=${playq_art[$playq_front]}
    local sid=${playq_id[$playq_front]}

    stitle=$(switch_net_to_save "$stitle")
    salbum=$(switch_net_to_save "$salbum")
    sartist=$(switch_net_to_save "$sartist")

    stitle=$(switch_save_to_display "$stitle")
    salbum=$(switch_save_to_display "$salbum")
    sartist=$(switch_save_to_display "$sartist")

    if [ "$SCRO_OPT" = "1" ]; then
	nohup python3 -c 'import scrobble; scrobble.Scrobble_one("'"$stitle"'", "'"$salbum"'", "'"$sartist"'")' >/dev/null 2>&1 &
    fi


    clear
    show_ui "$stitle" "$salbum" "$sartist" "$sid"
    play
    pop_playq
}



if [ "$MOEFM_DATABASE" = "" ]; then
    echo -e "\e[1m\e[36mYou haven't set a database direction!\e[0m"
    echo -e "After set database direction, please \e[1m\e[31mRESTART\e[0m the terminal"
    echo -e "Enter database direction (default \e[1m\e[33m~/moefm_file\e[0m)\e[1m\e[32m"
    read dab
    if [ "$dab" = "" ]; then 
	dab="$HOME/moefm_file"
    fi

    dab=${dab/'~'/''$HOME''}
    echo "export MOEFM_DATABASE=$dab" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    mkdir $dab
    touch $dab/database
    exit 0
fi

while true; do

    if [ "$SEAR_OPT" = "1" ]; then
	if [ "$ABS_LOCAL" = "1" ]; then
	    search_local $KEYWORDS
	else
	    search $KEYWORDS
	fi
    fi

    if [ -n "$ALBUM_ARG" ]; then
	require_list "&music=$ALBUM_ARG"
    fi

    if [ -n "$SONG_ARG" ]; then
	require_list "&song=$SONG_ARG"
    fi

    if [ -n "$RADIO_ARG" ]; then
	require_list "&radio=$RADIO_ARG"
    fi

    if [ -n "$FREE_OPT" ]; then
	require_list ""
    fi

    if [ "$*" = "" ]; then
	echo -e "Please enter an argument, use ./moefm.sh -h to get help"
	exit 0
    fi

    if [ "$(check_que_empty)" = "1" ]; then
	echo "There isn't any song..."
	exit 0
    fi

   while [ "$(check_que_empty)" = "0" ]; do

       play_a_song
   done

   if [ "$REPT_OPT" != 1 ]; then
       exit 0
   fi

done

