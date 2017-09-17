# 萌否电台bash脚本客户端

用终端听[萌否电台](http://moe.fm)。

[![moefm.sh运行在Lubuntu](assets/img/moefm.sh.png)](#安装和使用)

## 安装

Lubuntu / Ubuntu:

```bash
sudo apt-get install mpg123 curl jq git wget
```

OSX (with [Homebrew](https://brew.sh/)):

```
brew install mpg123 curl jq wget
```

执行:


```bash
git clone https://github.com/mike2718/moefm.sh.git
cd moefm.sh
./moefm.sh
```

## 参数

```bash
./moefm.sh -X
#随机播放一些歌曲

./moefm.sh -s 191459
#播放song_id为191459的歌曲
#相当于网页播放 http://moe.fm/listen/h5?song=191459

./moefm.sh -a 40276
#播放album_id为40276的整张专辑
#相当于 http://moe.fm/music/40276 

./moefm.sh -a 40276 -R
#随机播放列表(仅对 -a -s -r参数有效)

./moefm.sh -S "ぽっぴんジャンプ♪"
# 搜索这首歌曲并播放

./moefm.sh -l
# 混合模式，听歌的同时会保存歌曲到本地

./moefm.sh -L
# 离线模式，在本地数据库搜索歌曲（仅支持 -S 选项）

# 如果既没有 -l，也没有-L，为常规模式，
# 从网络上下载元数据并在本地检索，若存在歌曲即用本地文件播放，
# 不存在则用网络播放，但不保存到本地

./moefm.sh -c 100
# 把本地缓存的文件清理至 100MB 以下

./moefm.sh -C red
# 改变粗体字的颜色，
# 参数可以是black, red, green, yellow, blue, magenta, cyan和white
# 默认为蓝色

./moefm.sh -R
# 循环播放



./moefm.sh -h
#显示参数表
```

## 快捷键

* `s` `SPACE`: 暂停/继续播放
* `q` `Ctrl-C`: 跳到下一首曲目
* `Ctrl-Z`: 退出

## 使用协议
[MIT](https://github.com/mike2718/moefm.sh/blob/master/LICENSE)
