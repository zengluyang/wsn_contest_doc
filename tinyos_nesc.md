#开发环境搭建
##安装TinyOS工具链
###清理之前的安装
	sudo dpkg -P `dpkg -l nesc '*tinyos*' | grep ^ii | awk '{ print $2 }' | xargs`
	sudo apt-get clean

###添加tinyprod源
	cd /etc/apt/sources.list.d
	sudo echo "deb http://tinyprod.net/repos/debian squeeze main" >> tinyprod-debian.list
	sudo echo "deb http://tinyprod.net/repos/debian msp430-46 main" >> tinyprod-debian.list
###安装相应工具链
	sudo apt-get update
	sudo apt-get install nesc tinyos-tools msp430-46 avr-tinyos
##安装TinyOS

###下载并解压

	#进入用户目录
	cd ~
	#下载并解压
	wget http://github.com/tinyos/tinyos-release/archive/tinyos-2_1_2.tar.gz
	tar xf tinyos-2_1_2.tar.gz
	#将文件夹改名为tinyos-main
	mv tinyos-release-tinyos-2_1_2 tinyos-main
	cd tinyos-main
	#创建环境变量配置文件
	touch tinyos.env
	sudo chmod +x tinyos.env
	gedit tinyos.env
加入下列配置

	export TOSROOT="/home/xxx/tinyos-main" 
	#xxx为用户名
	export TOSDIR="$TOSROOT/tos"
	export CLASSPATH=$CLASSPATH:$TOSROOT/support/sdk/java
	export MAKERULES="$TOSROOT/support/make/Makerules"
	export PYTHONPATH=$PYTHONPATH:$TOSROOT/support/sdk/python
	echo "setting up TinyOS on source path $TOSROOT"

将`tinyos.env`加入`.bashrc`

	sudo gedit .bashrc
在最后一行加入
	source /home/xxx/tinyos-main/tinyos.env
重启终端

	echo $TOSROOT

查看是否为`/home/xxx/tinyos-main`，已确认环境变量已经生效
###配置环境变量
##编译例程
	#进入tinyos安装目录：
	cd $TOSROOT
	cd apps
	#选择一个需要编译的程序
	cd Blink
	#编译
	make telosb
显示`...compiled BlinkAppC to build/telosb/main.exe
...`说明编译成功
	
##TinyOS Tutorials
[http://tinyos.stanford.edu/tinyos-wiki/index.php/TinyOS_Tutorials](http://tinyos.stanford.edu/tinyos-wiki/index.php/TinyOS_Tutorials)

##安装TOSSIM
[http://tinyos.stanford.edu/tinyos-wiki/index.php/TOSSIM](http://tinyos.stanford.edu/tinyos-wiki/index.php/TOSSIM "TOSSIM")

