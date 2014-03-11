moefmcmd.sh
===========

![moefmcmd.sh运行在Ubuntu](img/screen.png)

运行在Ubuntu上的萌否电台客户端bash脚本。可以用终端听萌否电台唷~
 
## 安装和使用 ##

在Ubuntu的终端上，执行

```bash
sudo apt-get install mpg123 curl jq
git clone https://github.com/mike2718/moefmcmd
cd moefmcmd
chmod 755 moefmcmd.sh
./moefmcmd.sh
```

## 快捷键  ##

* `s` `SPACE`: 暂停/继续播放
* `q` `Ctrl-C`: 跳到下一首曲目
* `Ctrl-Z`: 退出

## 更便利的使用方法 ##

变成随处可运行的客户端。

```bash
cd moefmcmd
mkdir ~/bin
cp moefmcmd.sh ~/bin
. ~/.bashrc
moefmcmd.sh
```
