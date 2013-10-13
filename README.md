moefmcmd.sh
===========

运行在Linux上的萌否电台客户端bash脚本（试尝版）。本脚本为怀旧系无线电爱好者专版，不提供更复杂功能，不喜勿用，ZB什么的最讨厌了！讨厌，讨厌，最不喜欢你了！

在Ubuntu 12.04 LTS测试。
 
## 依赖软件 ##

用以下版本测试

* [jq](http://stedolan.github.io/jq/) 1.3
* [mpg123](http://www.mpg123.de/) 1.16.0
* [curl](http://curl.haxx.se/) 7.22.0

## 使用方法 ##

```sh
curl -ROL http://stedolan.github.io/jq/download/source/jq-1.3.tar.gz
tar -zxvf jq-1.3.tar.gz
cd jq-1.3
./configure
make
sudo make install
sudo apt-get install mpg123 curl
curl -ROL https://github.com/mike2718/moefmcmd/raw/master/moefmcmd.sh
chmod +x moefmcmd.sh
./moefmcmd.sh
```

如果要跳过当前曲目，按`Ctrl-C`一次。如果要关闭客户端，按`Ctrl-Z`。
