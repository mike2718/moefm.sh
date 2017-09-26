#!/bin/bash
#
# 萌否电台bash脚本客户端
# moe.fm bash script
#
# History:
#   2013/10/12  Mike Akiba
#   2015/3/3    Desmond Ding
#   2017/9/17   3usi9

# 工作逻辑：

# #######搜索######################
# 1.查找数据库
# search() 查找网络数据库
# search_local() 查找本地数据库

# 2.将找到的结果压入队列
# push_playq() 在队尾追加元素
# pop_playq() 弹出队头元素
# change_playq_front() 修改队头元素

# #######播放#####################

# 3.取出队头元素，检查title是否已决定(song_id已知)，若没有，从moefm上下载歌曲信息

# 4.检查是否打开下载开关，如果打开，下载这首歌

# 5.播放队头歌曲,检查是否打开Last.fm同步开关，若打开，将播放记录上传到Last.fm

# 6.弹出队头，如果队列非空，继续取出下一个队头元素

# ########下载###################

# 检查本地数据库是否存在
# 	若存在，检查文件是否完整
# 		若完整，直接返回，并将队头的播放路径改为本地歌曲路径
# 		否则，从网络上下载这首歌曲
# 	若不存在，从网络上下载这首歌曲

# 数据库条目格式：
# song_id####song_title####song_album####song_artist
# 比如：
# 歌曲ID为 1234 ，title为 Hello world , album为 Goodbyeworld , artist为I'm world
# 数据库中的条目：
# 1234####Hello%20world####Goodbyeworld####I&#039;m%20world






# URL part
BASE_URL='http://moe.fm/listen/playlist?api=json'
# moefm play API(所谓'专用接口')
SEARCH_URL='http://api.moefou.org/search/sub.json?sub_type=song'
W3MIMG_PATH='/usr/lib/w3m/w3mimgdisplay'
# moefm search API(通用借口，搜索[子条目(单首歌曲)])
# TODO: 增加搜索wiki(专辑/相关列表)的功能
API_KEY='&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8'
DATABASE_DIR=$MOEFM_DATABASE
DATABASE="$DATABASE_DIR"
DATABASE+="/database"
# DATABASE里保存了下载到本地的歌曲和metadata

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
    # 压入队尾
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
    # 弹出队头
    playq_front=$(($playq_front+1))
}

change_playq_front()
{
    # 修改队头
    playq_url[$playq_front]=$1
    playq_tit[$playq_front]=$2
    playq_alb[$playq_front]=$3
    playq_art[$playq_front]=$4
    playq_id[$playq_front]=$5
    playq_size[$playq_front]=$6
    cover_url[$playq_back]=$7
}
# 一会儿搜索的时候需要用到修改队头的功能

check_que_empty()
{
    # 检查队列是否空
    if [ "$playq_front" = "$playq_back" ]; then
	echo "1"
    else
	echo "0"
    fi
}

check_str_empty()
{
    # 检查字符串是否空
    local param=$*
    local str_empty="未知"

    if [ -z "$param" ]; then
        param=$str_empty
    fi

    echo "$param"
}

switch_net_to_save()
# 将网络上的文件名改为本地保存的文件名(数据库里不能有' ', 这是for .. in .. 的分隔符，所以把所有的' '替换为'%20')
{
    local str=$*;
    str=${str//' '/'%20'};
    echo "$str"
}


switch_save_to_display()
# 将数据库中的数据转换为可视数据
# 数据库里的条目应当避免出现 ' < > '_'(空格)等字符
{
    local str=$*;
    str=${str//'&#039;'/"'"}
    str=${str//'&#39;'/"'"}
    str=${str//'&lt;'/'<'}
    str=${str//'&gt;'/'>'}
    str=${str//'%20'/' '}
    str=${str//'&quot;'/'"'}
    str=${str//'&#34;'/'"'}
    str=${str//'&amp;'/'&'}
    str=${str//'&#38;'/'&'}
    
    echo "$str"
}

switch_display_to_save()
# 将可视数据转换为数据库中可保存的数据
{
    local str=$*;
    str=${str//"'"/'&#039;'}
    str=${str//"<"/'&lt;'}
    str=${str//">"/'&gt;'}
    str=${str//" "/'%20'}
    str=${str//'"'/'&#34;'}
    str=${str//'&'/'&amp;'}
    echo "$str"
}


show_cover()
# 展示专辑封面(测试中...不对，待测试...)
# 传入参数：专辑封面的网址
{    
    local url=$*

    echo -e "`tput rc`"    
#    echo "HIT!"
    # delete it after tested

    nohup wget -O "$DATABASE_DIR/opt.jpg"  "$url" >/dev/null 2>&1
    # 应对网络不稳定的情况，所以先下载到本地再显示...


    echo -e "0;1;1;150;300;300;;;300;300;$DATABASE_DIR/opt.jpg\n4;\n3;" | /usr/lib/w3m/w3mimgdisplay 



}


block_song()
# 过滤歌曲的函数...如果传入参数中包含filter的敏感词就返回false，否则返回true
{
    local keywd="$*"
    keywd=$(switch_display_to_save $keywd)
    local blocked="0"

    # 逐行读取filter
    for line in $(<"$DATABASE_DIR/filter")
    do
	res=$(echo "$keywd" | grep -i "$line")

	#	if [[ "$keywd" =~ "$line" ]]; then
	if [ "$res" != "" ]; then
	    blocked="1"

	    break
	fi
    done

    if [ "$blocked" = "0" ]; then
	echo "true"
    else
	echo "false"
    fi
}


love_track()
# Last.fm Love a song...
# 传入数据：song_id
{
    local id=$*
    local url=$BASE_URL
    url+="&song=$id"
    url+=$API_KEY
    local moefm_json=$(curl -s -A moefm.sh echo $url)
    # 请求json
    
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

    local vect="$id####$title####$album####$artist####1"
    
    title=$(switch_save_to_display "$title")
    album=$(switch_save_to_display "$album")
    artist=$(switch_save_to_display "$artist")

    python3 -c 'import scrobble; scrobble.Love_one("'"$title"'", "'"$album"'", "'"$artist"'")' >/dev/null 2>&1


    local res=$(cat $DATABASE | grep "$id")


    if [ "$res" != "" ]; then
	# 数据库中有这首歌曲
	sed -i '/^'"$id"'/d' $DATABASE
	# delete previous entry
	echo "$vect" >>  $DATABASE
	# Add a new entry
    fi

    # 调用python库.., 见scrobble.py
    echo -e "\e[1m\e[33m$title\e[0m - \e[1m\e[32m$artist\e[0m loved"


    # 其实个人还是喜欢手写ASCII Character...
    # echo -e 表示使用ASCII Escape符号
    # \e表示Escape
    # \e[0m 恢复无属性
    # \e[1m 粗体字
    # \e[31m 红色前景(字体)
    # \e[41m 红色背景(会把背景图片遮住所以很不爽)

}

pure_download()
# moefm.sh -D 选项，只下载一首歌曲
# 传入歌曲ID
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
    # 歌曲以id作为名称保存到数据库中
    
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
    # 转换为数据库条目格式
    
    local vect="$id####$title####$album####$artist"
    # 见文件头部的说明
    
    local res=$(cat $DATABASE | grep "$id")

    if [ "$res" = "" ]; then
	# 数据库中没有这首歌曲
	echo $vect >> $DATABASE
	# 将其(metadata)添加到数据库
	
	wget "$mp3_url" -O "$path" --progress=bar:force 2>&1 | tail -f -n +8
	echo "下载完成！"
	# Add the entry
    else
	# 数据库中有这首歌曲
	local file_size=$(du -a "$path" | awk '{print $1}')
	# 本地文件大小
	# $song_siz 的定义在这个函数前面title的那部分...值为服务器上保存的歌曲的文件大小
	
	local delta=$(($file_size-$song_siz))
	delta=${delta#-}
	# 取绝对值

	if [ $delta -gt 10 ]; then
	    # -gt 为greater than
	    ### FILE_BROKEN!
	    rm "$path"
	    # 删除文件
	    
	    sed -i '/^'"$id"'/d' $DATABASE
	    # 删除数据库中的条目
	    

	    echo $vect >> $DATABASE
	    # 新增这个条目到数据库
	    # (不要问我为什么先删后增...我也想代码复用啊[这就是你把后面的代码粘贴过来的理由？])
	    wget "$mp3_url" -O "$path" --progress=bar:force 2>&1 | tail -f -n +8
	    # tail命令截取wget中进度条的一部分
	    
	    echo "下载完成！"
	else
	    echo "条目已存在！"
	fi
    fi

}


show_ui()
# 展示UI
# 传入歌曲的metadata
{
    TITLE="曲名:   ${bold}${COLOR_ARG}%s\n${reset}"
    ALBUM="专辑:   ${bold}${COLOR_ARG}%s\n${reset}"
    ARTIST="艺术家: ${bold}${COLOR_ARG}%s\n${reset}"
    ID="歌曲ID: ${bold}${COLOR_ARG}%s\n\n${reset}"
    CONTROLLER="${bold}${COLOR_ARG}[SPACE]${reset} 暂停/继续 ${bold}${COLOR_ARG}[q]${reset} 下一曲 ${bold}${COLOR_ARG}[Ctrl-Z]${reset} 退出\n"
    
    UI=$TITLE$ALBUM$ARTIST$ID$CONTROLLER

    printf "`tput sc`$UI" "$1" "$2" "$3" "$4"

    if [ "$COV_OPT" = "1" ]; then
	show_cover "${cover_url[$playq_front]}"
    fi
}

# 用这个奇怪的队列之后，我其实已经不知道怎么打乱顺序了...
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
# 搜索本地数据库
# 传入值：keyword
{
    local keywd=$*
    keywd=$(switch_display_to_save "$keywd");

    res=$(cat $DATABASE | grep -i "$keywd")

    for i in $(echo $res)
	     # 这里i的分隔是用空格(或换行符)做标识符的，所以要把歌曲名中的空格改为%20
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
# 搜索网络数据库
# 传入值：keyword
{

    local keywd=$*
    keywd=${keywd//' '/'%20'}
    # 相当于switch_display_to_net, 本着不改代码的原则放着不动

    SEARCH_URL+="&keyword="
    SEARCH_URL+=$keywd
    SEARCH_URL+=$API_KEY

    search_json=$(curl -s -A moefm.sh echo $SEARCH_URL)
    search_entries=$(echo $search_json | jq -M -r ".response.information.count")

    for((i=0;i<search_entries;i++))
    do
	local query=$(echo $search_json | jq -M -r ".response.subs[$i].sub_upload")
	# sub_upload指歌曲是否有人上传音乐文件，如果为空，moe.fm会随机抽一首(与关键字无关的)歌曲返回
	if [ "$query" != "[]" ]; then
	    # valid
	    local s_id=$(echo $search_json | jq -M -r ".response.subs[$i].sub_id")
	    local s_url=$BASE_URL
	    s_url+="&song=$s_id"
	    s_url+=$API_KEY
	    push_playq "$s_url" "to_be_resolved" "to_be_resolved" "to_be_resolved" "$s_id" "to_be_resolved" "to_be_resolved"
	    # moe.fm的搜索API只返回了歌曲的id和是否存在的信息，歌曲的metadata需要在播放时再查询
	    # (当然也不排除我没看见返回的metadata...这里求改善)
	fi
    done
    # push valid songs into play queue

}

require_list()
# 用参数发起一个对moe.fm play API的GET请求
# 输入：参数(比如"&music=3456", 查找id为3456的专辑)
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
	# song_siz为(核对数据库使用的)歌曲大小
	# song_cov为封面图片

	title=$(check_str_empty $title)
	album=$(check_str_empty $album)
	artist=$(check_str_empty $artist)

	push_playq "$mp3_url" "$title" "$album" "$artist" "$song_id" "$song_siz" "$song_cov"
    done
}


resolve_json()
# 刚才提到的"dynamically resolve",
# 针对metadata为"to_be_resolved"的歌曲, 发起一个请求获得metadata
{
    local url=$1
    local moefm_json=$(curl -s -A moefm.sh echo $url)
    local items=$(echo $moefm_json | jq -M -r ".response.information.item_count")
    # 'items' only can be 1
    
    for((i=0;i<$items;i++))
    do
	local mp3_url=$(echo $moefm_json | jq -M -r ".response.playlist[$i].url")
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
	# 这里使用了不该使用的函数....求改善(完全封装住播放队列)
	# 在本程序中，这个函数接受的url只可能是队头的元素...所以这样写...
    done

}


# main function
# 约定OPT表示是否选择，ARG为选项参数
while getopts "a:c:C:D:F:s:S:r:AfRhlLUXI" arg
do
    case $arg in
	a)
	    ALBUM_ARG=$OPTARG;;

	A)
	    ABS_LOCAL=1
	    LOC_ALL_OPT=1;;

	C)
	    tmp=$OPTARG
	    COLOR_ARG=`eval echo '$'"$tmp"`;;

	D)
	    ARG=$OPTARG
	    pure_download $ARG
	    exit 0;;

	f)
	    LOC_LOV_OPT=1;;

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
-A            [with -L] Playing all local songs
-C <COLOR>    Set UI Color
-D <SONG_ID>  Download a song
-F <SONG_ID>  Love a song
-f            [with -L] Playing loved songs
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
# 下载一首歌(这个函数以及下面的play的耦合度不是一般的高，有必要重写)
# 输入：文件保存的位置
# 返回值：最终决定的播放路径(本地文件/网址)
{
    local path=$1

    local sid=${playq_id[$playq_front]}
    local stitle=${playq_tit[$playq_front]}
    local salbum=${playq_alb[$playq_front]}
    local sartist=${playq_art[$playq_front]}
    # 直接调用了队头元素...需要封装一下
    stitle=$(switch_net_to_save "$stitle")
    salbum=$(switch_net_to_save "$salbum")
    sartist=$(switch_net_to_save "$sartist")

    local vect="$sid####$stitle####$salbum####$sartist"

    local res=$(cat $DATABASE | grep "$sid")
    if [ "$res" = "" ]; then
	# 数据库中没有条目
	if [ "$MIX_OPT" = "1" ]; then
	    # 如果打开 -l 选项就下载这首歌
	  nohup wget -q "${playq_url[$playq_front]}" -O "$path" >/dev/null 2>&1 &
	    echo $vect >> $DATABASE
	fi
	echo "${playq_url[$playq_front]}"
	
	# return

    else
	# 数据库中有条目
	local file_size=$(du -a "$path" | awk '{print $1}')
	local delta=$(($file_size-${playq_size[$playq_front]}))
	delta=${delta#-}

	if [ $delta -lt 10 ]; then
	    # 文件是完整的
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
# 播放队头的歌曲
{
    local file_path="$DATABASE_DIR"
    file_path+="/${playq_id[$playq_front]}.mp3"
    if [ "$ABS_LOCAL" = "1" ]; then
	# -L 选项，本地查找(因为没有进行完整性检查所以可能播放一半...但总比什么都听不到要好)
 	mpg123 -q -C "$file_path" 
	
    else
	local final_path=$(download $file_path)
	# 得到最终决定的播放地址[见download()]
	mpg123 -q -C "$final_path"
    fi
}


play_a_song()
{
# 显示，播放并同步队头的歌曲
    if [ "${playq_tit[$playq_front]}" = "to_be_resolved" ]; then
	resolve_json "${playq_url[$playq_front]}"
	# dynamically resolving
    fi

    local sid=${playq_id[$playq_front]}
    local stitle=${playq_tit[$playq_front]}
    local salbum=${playq_alb[$playq_front]}
    local sartist=${playq_art[$playq_front]}
    local sid=${playq_id[$playq_front]}

    stitle=$(switch_net_to_save "$stitle")
    salbum=$(switch_net_to_save "$salbum")
    sartist=$(switch_net_to_save "$sartist")
    

    ass=$(block_song "$stitle")
    # 判断是否在filter列表中


    if [ "$ass" = "true" ]; then
	# 不在filter列表中
	stitle=$(switch_save_to_display "$stitle")
	salbum=$(switch_save_to_display "$salbum")
	sartist=$(switch_save_to_display "$sartist")

	if [ "$SCRO_OPT" = "1" ]; then
	    # -U 选项，同步到last.fm
	    nohup python3 -c 'import scrobble; scrobble.Scrobble_one("'"$stitle"'", "'"$salbum"'", "'"$sartist"'")' >/dev/null 2>&1 &
	fi

	if [ "$LOC_LOV_OPT" = "1" -a "$ABS_LOCAL" = "1"  ]; then
	    local vect=$(cat $DATABASE | grep "$sid")
	    local lov=$(echo "$vect" | awk -F '####' '{print $5}')
	    if [ "$lov" == "" ]; then
		pop_playq
		return
	    fi
	fi


	clear
	show_ui "$stitle" "$salbum" "$sartist" "$sid"
	play


    fi
    pop_playq
}


# 检查是否设置了数据库路径
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
    touch "$dab/database"
    touch "$dab/filter"
    exit 0
fi

while true; do

    if [ "$SEAR_OPT" = "1" ]; then
	# -S 选项，搜索
	if [ "$ABS_LOCAL" = "1" ]; then
	    # -L 选项，本地搜索
	    search_local $KEYWORDS
	else
	    search $KEYWORDS
	fi
    fi

    if [ -n "$ALBUM_ARG" ]; then
	# -a 选项，播放指定专辑
	require_list "&music=$ALBUM_ARG"
    fi

    if [ -n "$SONG_ARG" ]; then
	# -s 选项，播放单首歌曲
	require_list "&song=$SONG_ARG"
    fi

    if [ -n "$RADIO_ARG" ]; then
	# -r 选项，播放个人电台
	require_list "&radio=$RADIO_ARG"
    fi

    if [ -n "$LOC_ALL_OPT" ]; then
	search_local "#"
    fi
    
    if [ -n "$FREE_OPT" ]; then
	# -X 选项，自由播放
	require_list ""
    fi

    if [ "$*" = "" ]; then
	# 什么都没有输入...
	# 随便播放吧~
	#	echo -e "Please enter an argument, use ./moefm.sh -h to get help"
	REPT_OPT=1
	require_list ""
    fi

    if [ "$(check_que_empty)" = "1" ]; then
	# 队列里空空如也..
	echo "There isn't any song..."
	exit 0
    fi

   while [ "$(check_que_empty)" = "0" ]; do
       play_a_song
   done

   if [ "$REPT_OPT" != 1 ]; then
       # -R 选项，循环播放
       exit 0
   fi

done



# 下一步计划：
# 1.用Qt和C++重写播放的核心功能与UI(明明想做GUI嘛~不要违背自己的意愿嘛~)
#	采用OOP范式(函数式要写一个大一点儿的项目其实真的力不从心...)
# 2.扩展模块采用Python写，交互采用Shell(这才是Shell派上用场的时候！)
# 3.不知道下次填这个坑是啥时候了...

# Mail me: Templ_1@outlook.com
# github的账号是小号, 不经常上，可能不能很快答复
