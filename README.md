moefmcmd.sh
===========

运行在Linux上的萌否电台客户端bash脚本（试尝版）。本脚本为怀旧系无线电爱好者专版，不提供更复杂功能，不喜勿用，ZB什么的最讨厌了！讨厌，讨厌，最不喜欢你了！

在Ubuntu 12.04 LTS测试。
 
## 依赖软件 ##
* [jq](http://stedolan.github.io/jq/) 1.3: 使用稳定版本的jq，用于解析萌否API的json
* [mpg321](http://mpg321.sourceforge.net/) 0.2.13: 用于命令行播放网络上的mp3文件
* [curl](http://curl.haxx.se/) 7.22.0: 命令行版本的下载工具，用于获取萌否json

## 使用方法 ##

```sh
wget http://stedolan.github.io/jq/download/source/jq-1.3.tar.gz
tar -zxvf jq-1.3.tar.gz
cd jq-1.3
./configure
make
sudo make install

sudo apt-get install mpg321 curl

curl -ROL https://github.com/mike2718/moefmcmd/raw/master/moefoufmcmd.sh
chmod +x moefmcmd.sh
./moefmcmd.sh
```

如果要切换歌曲，按`Ctrl-C`一次。如果要关闭客户端，按`Ctrl-Z`。
