moefmcmd.sh
===========

运行在Linux上的萌否电台客户端shell脚本（试尝版）。本脚本为m酱的极简主义专版萌否电台客户端~
 
## 依赖软件 ##

用以下版本测试

* [jq](http://stedolan.github.io/jq/) 1.3
* [mpg123](http://www.mpg123.de/) 1.16.0
* [curl](http://curl.haxx.se/) 7.22.0

## 使用方法 ##

在Ubuntu上，

```sh
curl -ROL http://stedolan.github.io/jq/download/source/jq-1.3.tar.gz
tar -zxvf jq-1.3.tar.gz
cd jq-1.3
./configure
make
sudo make install
sudo apt-get install mpg123 curl
curl -ROL https://github.com/mike2718/moefmcmd/raw/master/moefmcmd.sh
chmod 755 moefmcmd.sh
./moefmcmd.sh
```

* `SPACE` `s`: 暂停播放，再按一次为继续播放
* `q` `Ctrl-C`: 跳到下一首曲目
* `Ctrl-Z`: 退出程序

