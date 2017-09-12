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
