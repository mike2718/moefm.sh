#!/bin/bash
#
# 萌否电台本地数据库管理工具
# moefm.sh database manager
#
# History:
#   2017/9/18   3usi9


DATABASE_DIR=$MOEFM_DATABASE
DATABASE="$DATABASE_DIR"
DATABASE+="/database"
OPT_DIR="$HOME/moefm_export"



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



remove_sing()
{
    local sid=$*
    echo $sid
    sed -i '/^'"$sid"'/d' $DATABASE
    local path="$DATABASE_DIR"
    path+="/$sid.mp3"
    rm "$path"
    echo -e "ID为\e[1m\e[33m$sid\e[0m的歌曲已从数据库中移出"
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


clean()
{
    local size=$*
    local tomb=1024
    size=$((size*tomb))
    
    local file_tab=$(ls -altur --time-style=iso "$DATABASE_DIR" | grep "^-" | grep -v "database" | awk '{print $8}')


 for i in $file_tab
 do
     local cursize=$(du  "$DATABASE_DIR" | awk '{print $1}')
     local file_id=$(echo $i | awk -F '.' '{print $1}')
     #   sed -i '/^'"$sid"'/d' $DATABASE

     if [ $cursize -lt $size ]; then
   	 break
     fi
     rm "$DATABASE_DIR/$i"
     sed -i '/^'"$file_id"'/d' $DATABASE     
   done
 echo "Clean complete!"
}

clear_database()
# haven't test
{
    echo -e "这项操作会\e[1m\e[31m删除\e[0m本地数据库中的\e[1m\e[31m所有歌曲\e[0m\n并且\e[1m\e[31m不可撤销\e[0m！"
    echo -e "请确保\e[1m\e[33mmoefm.sh没有运行\e[0m"
    echo -e "请确认(\e[1m\e[31myes\e[0m/\e[32m\e[1mno\e[0m)"
    while true
    do
	read ans
	if [ "$ans" = "yes" ]; then
	    echo -e "正在清理数据库..."
	    rm -r "$DATABASE_DIR/"
	    mkdir "$DATABASE_DIR"
	    touch "$DATABASE_DIR/database"
	    break
	elif [ "$ans" = "no" ]; then
	    echo -e "取消操作..."
	    break
	else
	    echo -e "请输入\e[1m\e[31myes\e[0m/\e[32m\e[1mno\e[0m, 按\e[1m\e[33mCtrl-C\e[0m可以强制结束"
	fi
    done
}

dump_all()
{
    clear
    if [ ! -d "$OPT_DIR" ]; then
	echo -e "导出文件夹不存在，将创建..."
	mkdir "$OPT_DIR"
	echo -e "导出路径为\e[1m\e[33m$OPT_DIR\e[0m"
    fi
    echo "正在导出数据库内所有歌曲..."
    local db=$(cat $DATABASE)
    local cnt=1
    local tot=$(cat $DATABASE | grep -c "####")
    echo -e "正在导出第  `tput sc`\e[1m\e[32m$cnt\e[0m  首歌曲，共有  \e[1m\e[33m$tot\e[0m  首歌曲"
    for i in $(echo $db)
    do
	echo -e "\e[1m\e[32m`tput rc`$cnt\e[0m"
	cnt=$((cnt+1))
	local id=$(echo $i | awk -F '####' '{print $1}')
	local tit=$(echo $i | awk -F '####' '{print $2}')
	local alb=$(echo $i | awk -F '####' '{print $3}')
	local art=$(echo $i | awk -F '####' '{print $4}')
	id=${id//'%20'/' '}
	tit=${tit//'%20'/' '}
	alb=${alb//'%20'/' '}
	art=${art//'%20'/' '}

	local path="$DATABASE_DIR/$id.mp3"
	mp3info -t "$tit" -a "$art" -l "$alb" "$path"
	# Added mp3 metadata....

	tit=${tit//'/'/'／'}
	alb=${alb//'/'/'／'}
	cp "$path" "$OPT_DIR/$tit - $alb.mp3"

    done


}

dump_one()
{
    arg=$*
    clear
    if [ ! -d "$OPT_DIR" ]; then
	echo -e "导出文件夹不存在，将创建..."
	mkdir "$OPT_DIR"
	echo -e "导出路径为\e[1m\e[33m$OPT_DIR\e[0m"
    fi
    son=$(cat $DATABASE | grep -i "$arg")

    if [ "$son" = "" ]; then
	echo "该歌曲不存在..."
	exit 0
    else

	for i in $(echo $son)
	do

	    local id=$(echo $i | awk -F '####' '{print $1}')
	    local tit=$(echo $i | awk -F '####' '{print $2}')
	    local alb=$(echo $i | awk -F '####' '{print $3}')
	    local art=$(echo $i | awk -F '####' '{print $4}')
	    id=${id//'%20'/' '}
	    tit=${tit//'%20'/' '}
	    alb=${alb//'%20'/' '}
	    art=${art//'%20'/' '}

	    local path="$DATABASE_DIR/$id.mp3"
	    mp3info -t "$tit" -a "$art" -l "$alb" "$path"
	    # Added mp3 metadata....
	    echo -e "正在导出：\e[1m\e[33m$tit\e[0m"
	    tit=${tit//'/'/'／'}
	    alb=${alb//'/'/'／'}
	    cp "$path" "$OPT_DIR/$tit - $alb.mp3"
	done
    fi
}

search_database()
{
    arg=$*
    arg=$(switch_display_to_save "$arg")
    clear
    son=$(cat $DATABASE | grep -i "$arg")

    if [ "$son" = "" ]; then
	echo "该歌曲不存在..."
	exit 0
    else
	for i in $(echo $son)
	do

	    local id=$(echo $i | awk -F '####' '{print $1}')
	    local tit=$(echo $i | awk -F '####' '{print $2}')
	    local alb=$(echo $i | awk -F '####' '{print $3}')
	    local art=$(echo $i | awk -F '####' '{print $4}')
	    id=$(switch_save_to_display "$id")
	    tit=$(switch_save_to_display "$tit")
	    alb=$(switch_save_to_display "$alb")
	    art=$(switch_save_to_display "$art")

	    echo -e "曲名: \e[1m\e[33m$tit\e[0m"
	    echo -e "专辑: \e[1m\e[33m$alb\e[0m"
	    echo -e "艺术家: \e[1m\e[33m$art\e[0m"
	    echo -e "歌曲ID: \e[1m\e[33m$id\e[0m\n\n"

	done
    fi
}


while getopts "c:e:d:O:S:DEh" arg
do
    case $arg in
	c)
	    clean $OPTARG;;

	e)
	    DUMP_ARG=$OPTARG
	    DUMP_OPT=1;;

	E)
	    DUMP_ALL=1;;

	d)
	    remove_sing $OPTARG;;

	D)
	    clear_database;;

	O)
	    tmp=$OPTARG

	    tmp=${tmp/'~'/''$HOME''}
	    OPT_DIR="$tmp";;

	S)
	    search_database $OPTARG;;

	h)
	    echo -e "usage: moedatabase.sh [option(s)]\n
-c <SIZE>     clean database to <SIZE> (MB)
-e <KEYWORD>  Export songs contain <KEYWORD>
-E            Export all songs
-d <SONG_ID>  Remove a song with <SONG_ID>
-D            Remove All songs in database
-O            Set output directory (default ~/moefm_export
-S <KEYWORD>  Search songs in local database
-h            Show this help page"

    esac
done

if [ "$*" = "" ]; then
    echo "Moefm Database Manager
use moedatabase.sh -h to get help"
fi

if [ "$DUMP_OPT" = "1" ]; then
    dump_one $DUMP_ARG
fi

if [ "$DUMP_ALL" = "1" ]; then
    dump_all
fi
