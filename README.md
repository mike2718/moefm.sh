moefmcmd.sh
===========

运行在Linux上的萌否电台客户端shell脚本（试尝版）。本脚本为m酱的极简主义专版萌否电台客户端~
 
## 依赖软件 ##

* [TickTick](https://github.com/kristopolous/TickTick) 仓库内已包含
* [mpg123](http://www.mpg123.de/)
* [curl](http://curl.haxx.se/)

## 使用方法 ##

在Ubuntu上，执行

```bash
sudo apt-get install mpg123 curl
git clone https://github.com/mike2718/moefmcmd
cd moefmcmd
chmod 755 moefmcmd.sh
./moefmcmd.sh
```

* `s` `SPACE`: 暂停/继续播放
* `q` `Ctrl-C`: 跳到下一首曲目
* `Ctrl-Z`: 退出程序

## 更便利的使用方法 ##

直接丢到~/bin，随时运行

```bash
cd moefmcmd
mkdir ~/bin
cp *.sh ~/bin
. .bashrc
moefmcmd
```
