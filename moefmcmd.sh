#!/bin/bash
# 程序:
#     萌否电台客户端shell脚本
# 依赖软件:
#     mpg123, curl
# 历史:
# 2013/10/12	Mike Akiba	初次发布
. ticktick.sh

get_moefm_json () {
    curl -s -A moefmcmd.sh 'http://moe.fm/listen/playlist?api=json&api_key=4e229396346768a0c4ee2462d76eb0be052592bf8'
    return
}

while true; do
    tickParse "$(get_moefm_json)"
    number=$(curl -s -A moefmcmd.sh 'http://www.random.org/integers/?num=1&min=1&max=9&col=1&base=10&format=plain&rnd=new')
    case $number in
    # 懒人。。用这来解吧 http://www.commandlinefu.com/commands/view/2285/urldecoding
    # 尼马TickTick居然不吃变量替换这一套，灭法只能———强势插入！
        1)    mp3_url=`` response.playlist[0].url ``
              title=`` response.playlist[0].sub_title ``
              artist=`` response.playlist[0].artist ``
              album=`` response.playlist[0].wiki_title ``
              ;;
        2)    mp3_url=`` response.playlist[1].url ``
              title=`` response.playlist[1].sub_title ``
              artist=`` response.playlist[1].artist ``
              album=`` response.playlist[1].wiki_title ``
	      ;;
        3)    mp3_url=`` response.playlist[2].url ``
              title=`` response.playlist[2].sub_title ``
              artist=`` response.playlist[2].artist ``
              album=`` response.playlist[2].wiki_title ``
              ;;
        4)    mp3_url=`` response.playlist[3].url ``
              title=`` response.playlist[3].sub_title ``
              artist=`` response.playlist[3].artist ``
              album=`` response.playlist[3].wiki_title ``
              ;;
        5)    mp3_url=`` response.playlist[4].url ``
              title=`` response.playlist[4].sub_title ``
              artist=`` response.playlist[4].artist ``
              album=`` response.playlist[4].wiki_title ``
              ;;
        6)    mp3_url=`` response.playlist[5].url ``
              title=`` response.playlist[5].sub_title ``
              artist=`` response.playlist[5].artist ``
              album=`` response.playlist[5].wiki_title ``
              ;;
        7)    mp3_url=`` response.playlist[6].url ``
              title=`` response.playlist[6].sub_title ``
              artist=`` response.playlist[6].artist ``
              album=`` response.playlist[6].wiki_title ``
              ;;
        8)    mp3_url=`` response.playlist[7].url ``
              title=`` response.playlist[7].sub_title ``
              artist=`` response.playlist[7].artist ``
              album=`` response.playlist[7].wiki_title ``
              ;;
        9)    mp3_url=`` response.playlist[8].url ``
              title=`` response.playlist[8].sub_title ``
              artist=`` response.playlist[8].artist ``
              album=`` response.playlist[8].wiki_title ``
              ;;
        *)    echo "WTF!" >&2
              exit 1
              ;;
    esac
    mp3_url_decoded=$(echo $mp3_url | sed -e 's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
    title_decoded=$(echo -e $title | sed -e 's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
    artist_decoded=$(echo -e $artist | sed -e 's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
    album_decoded=$(echo -e $album | sed -e 's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
    clear
    echo "
 $title_decoded

艺术家: $artist_decoded
专辑:   $album_decoded

[SPACE] 暂停/继续 [q] 下一曲 [Ctrl-Z] 退出
"
    mpg123 -q -C $mp3_url_decoded
    done
