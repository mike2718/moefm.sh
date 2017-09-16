# 萌否电台bash脚本客户端

可以用终端听[萌否电台](http://moe.fm)。

[![moefm.sh运行在Ubuntu](assets/img/moefm.sh.png)](#安装和使用)

## 依赖软件

* [mpg123](http://www.mpg123.de/)
* [curl](http://curl.haxx.se/)
* [jq](http://stedolan.github.io/jq/)

Ubuntu:

```bash
sudo apt-get install mpg123 curl jq
```

OSX (with [Homebrew](https://brew.sh/)):

```
brew install mpg123 curl jq
```

## 安装

在终端上执行：

```bash
git clone https://github.com/mike2718/moefm.sh.git
cd moefm.sh
./moefm.sh
```

## 参数

```bash
./moefm.sh
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

./moefm.sh -h
#显示参数表
```

## 快捷键

* `s` `SPACE`: 暂停/继续播放
* `q` `Ctrl-C`: 跳到下一首曲目
* `Ctrl-Z`: 退出

## 更便利的使用方法

变成随处可运行的客户端。

```bash
cd moefm.sh
mkdir ~/bin
cp moefm.sh ~/bin
. ~/.bashrc
moefm.sh
```

## 使用协议
[MIT](https://github.com/mike2718/moefm.sh/blob/master/LICENSE)
