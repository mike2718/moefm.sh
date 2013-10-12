moefmcmd.sh
===========

Linux上的萌否电台客户端bash脚本（试尝版），可能有众多bug，请谨慎使用。由于使用造成的损失，本人概不负责。
在Ubuntu 12.04 LTS测试。
 
## 依赖软件 ##
* [jq](http://stedolan.github.io/jq/) 使用稳定版本的jq，用于解析萌否API的json
* [mpg123](http://www.mpg123.de/) 用于命令行播放网络上的mp3文件
* [curl](http://curl.haxx.se/) 命令行版本的下载工具，用于获取萌否json

## 使用方法 ##
1.  安装依赖的软件，Ubuntu上：
```Shell
sudo apt-get install mpg123 curl
```
[下载jd](http://stedolan.github.io/jq/download/)，设置环境变量
2.  从版本库获取moefmcmd
```Shell
git clone https://github.com/mike2718/moefmcmd
cd moefmcmd
```
3.  运行萌否客户端bash
```Shell
chmod u+x moefmcmd.sh
./moefmcmd.sh
```
如果要切换歌曲，按Ctrl-C一次，如果要关闭客户端，快速按Ctrl-C两次。
