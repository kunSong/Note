：#!/bin/bash
###########################################################################
# Copyright Statement:
# --------------------
# This software is protected by Copyright and the information contained
# herein is confidential. The software may not be copied and the information
# contained herein may not be used or disclosed except with the written
# permission of Magcomm Inc. (C) 2015
# -----------------
# Author : y.haiyang
# Version: V1.1
# Update : 2014-06-01
############################################################################
#需要添加的库，可以在此方便添加
readonly GAP=" "
# open jdk
readonly OPEN_JDK="openjdk-7-jdk"
# Android 基本的要求库
readonly ANDOID_BASE="vim git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 gawk lib32z1 m4 libxml2-utils"
# Android 内核高于3.5 的库
readonly ANDOID_BASE_MESA="libglapi-mesa:i386 libgl1-mesa-glx:i386"
# Android 内核低于3.5 的库
readonly ANDOID_BASE_MESA_LTS="libgl1-mesa-dev"
# 常用工具添加 
readonly COMMON_UTILS="nautilus-open-terminal rpm openssh-server gitk iptux"
# 经典桌面
readonly GNOME_PANEL="gnome-panel ubuntu-desktop"
# Samba服务器
#readonly SAMBA="samba smbfs samba-common-bin"
#modified by Yar cause installing smbfs error @20171106
readonly SAMBA="samba samba-common-bin"
# 亿赛通内核
readonly ULTRASEC_KERNEL="linux-image-extra-3.13.0-32-generic"
# 兼容Android4.4 的GCC
readonly COMPATIBLE_GCC="gcc-4.4 g++-4.4 gcc-4.4-multilib g++-4.4-multilib"
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 固定路径方便修改
readonly LOCAL_PATH=$PWD
#readonly INIT_PATH=$(dirname $(pwd))
readonly INIT_PATH=$LOCAL_PATH
readonly INIT_UTILS_PATH=$INIT_PATH/utils
readonly INIT_RESOURCE_PATH=$INIT_PATH/resource
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#配置宏控 方便以后选择性安装
# 添加SAMBA 服务器
readonly INSTALL_SAMBA=yes
# 添加亿赛通
readonly INSTALL_ULTRASEC=no
# 添加 oracle java jdk
readonly INSTALL_ORACLE_JDK=yes
# 添加Android工具
readonly INSTALL_ANDROID_TOOLS=yes
# 添加FlashTools 下载工具
readonly INSTALL_FLASH_TOOLS=yes
# 添加NX ，参数可以选 3,4 none
readonly INSTALL_NO_MACHINE=3
# 添加ADB驱动
readonly INSTALL_ADB_DRIVE=yes
# 添加经典桌面
readonly INSTALL_GNOME=no
# 安装Android 依赖库
readonly INSTALL_ANDROID_SOFT=no
# 选择Android 库的版本
#modified by Yar for high kernel use this @20171106
readonly CHOOSE_ANDROID_MESA=$ANDOID_BASE_MESA
#readonly CHOOSE_ANDROID_MESA=$ANDOID_BASE_MESA_LTS
# 安装OPEN JDK
readonly INSTALL_OPEN_JDK=yes
# 安装常用工具
readonly INSTALL_COMMON_UTILS=yes
# 兼容 Android 4.4 版本编译
readonly INSTALL_COMPATIBLE_GCC=yes
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function echoMe()
{
    echo -e "\e[01;32m*************************************************\e[0m"
    echo -e "\e[01;32m*\e[0m"

    for tag in "$@"
    do
        echo -e "\e[01;32m*\e[0m  \e[01;34m $tag \e[0m"
        echo -e "\e[01;32m*\e[0m"
    done

    echo -e "\e[01;32m*************************************************\e[0m"

}

function timing()
{
    local time=$1
    local tipStart=$2
    local tipEnd=$3

    while [ $time -ge 0 ]
        do
            echo -e  "\e[01;34m $tipStart\e[0m\e[01;31m$time\e[0m\e[01;34m$tipEnd \e[0m"
            sleep 1
            let "time-=1"
    done
}

##############################################################################
# 开始配置
timing 8 请确认联网, 秒后开始配置

echoMe "更新Ubuntu源！"
sudo apt-get update

#安装依赖库
echoMe "安装依赖库！"
if [[ $INSTALL_OPEN_JDK == yes ]] ; then
    INSTALL_SOFTS=$OPEN_JDK
fi

if [[ $INSTALL_ANDROID_SOFT == yes ]]  ; then
    INSTALL_SOFTS=${INSTALL_SOFTS}${GAP}${ANDOID_BASE}${GAP}${CHOOSE_ANDROID_MESA}
fi

if [[ $INSTALL_COMMON_UTILS == yes ]] ; then
    INSTALL_SOFTS=${INSTALL_SOFTS}${GAP}${COMMON_UTILS}
fi

if [[ $INSTALL_GNOME == yes ]] ; then
    INSTALL_SOFTS=${INSTALL_SOFTS}${GAP}${GNOME_PANEL}
fi

if [[ $INSTALL_SAMBA == yes ]] ; then
    INSTALL_SOFTS=${INSTALL_SOFTS}${GAP}${SAMBA}
fi

if [[ $INSTALL_ULTRASEC == yes ]] ; then
    INSTALL_SOFTS=${INSTALL_SOFTS}${GAP}${ULTRASEC_KERNEL}
fi

if [[ $INSTALL_COMPATIBLE_GCC == yes ]] ; then
    INSTALL_SOFTS=${INSTALL_SOFTS}${GAP}${COMPATIBLE_GCC}
fi

echo $INSTALL_SOFTS
sudo apt-get install $INSTALL_SOFTS

sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

# 设置OpenJDK版本
echoMe "请选择java版本 ：java-7-openjdk-amd64" "    可能为：2"
sudo update-alternatives --config java
sudo update-alternatives --config javac

#设置 opt目录的权限为777
sudo chmod 777  /opt

# 配置FlashTools
if [[ $INSTALL_FLASH_TOOLS == yes ]] ; then
    echoMe "添加FlashTools"
#modified by Yar for upgrade download tools @20171103 begin
#    tar -zxf $INIT_RESOURCE_PATH/FlashTools.tar.gz -C /opt
    tar -zxf $INIT_RESOURCE_PATH/mtk_tool-v5.1732.tar.gz -C /opt
    sudo chmod +x -R /opt/mtk_tool-v5.1732
#modified by Yar for upgrade download tools @20171103 end
fi


#添加Android驱动和下载驱动
if [[ $INSTALL_ADB_DRIVE == yes ]] ; then
    sudo mkdir -p /etc/udev/rules.d/
    sudo cp -a $INIT_UTILS_PATH/51-android.rules  /etc/udev/rules.d/
    sudo cp -a $INIT_UTILS_PATH/51-download.rules /etc/udev/rules.d/

    sudo chmod a+rx /etc/udev/rules.d/51-android.rules
    sudo chmod a+rx /etc/udev/rules.d/51-download.rules
#added by Yar for 'adb devices' @20171103 begin
    sudo cp -a $INIT_UTILS_PATH/70-android.rules  /etc/udev/rules.d/
    sudo chmod a+rx /etc/udev/rules.d/70-android.rules
    mkdir ~/.android
    cp $INIT_UTILS_PATH/adb_usb.ini ~/.android
#added by Yar for 'adb devices' @20171103 end
    sudo apt-get remove modemmanager
    sudo /etc/init.d/udev restart
    sudo modprobe cdc_acm
fi

    echo -e "\e[01;32m*************************************************\e[0m"
    echo -e "\e[01;32m*\e[0m"
    if [[ $INSTALL_ORACLE_JDK == yes ]] ; then
        echo -e "\e[01;32m*\e[0m  添加： Oracle java 1.6.0.45"
        # install sun jdk 1.6.0.45
        tar -zxf $INIT_PATH/jdk-6u45-linux-x64.tar.gz  -C /opt/
        # install sun jdk 1.7.0.80
        echo -e "\e[01;32m*\e[0m  添加： Oracle java 1.7.0.80"
        tar -zxf $INIT_PATH/jdk-7u80-linux-x64.tar.gz  -C /opt/
        # install sun jdk 1.8.0.45
        echo -e "\e[01;32m*\e[0m  添加： Oracle java 1.8.0.45"
        tar -zxf $INIT_PATH/jdk-8u45-linux-x64.tar.gz  -C /opt/
    fi
    
    if [[ $INSTALL_ANDROID_TOOLS == yes ]] ; then
        # install android sdk ,android-studio ,FlashTools
        echo -e "\e[01;32m*\e[0m  添加： Android SDK, AndroidStudio, FlashTools"
#modified by Yar for update android-sdk @20171103 begin
#        tar -zxf $INIT_RESOURCE_PATH/android-sdk.tar.gz -C /opt/
#modified by Yar for update android-sdk @20171103 end
        # AndroidStuido 设置开启第一次不加载Android SDK
        sudo sed -i '$a disable.android.first.run=true' /opt/android-studio/bin/idea.properties
    fi
    echo -e "\e[01;32m*************************************************\e[0m"

# 添加Magcomm 配置文件
if [[ ! -f /etc/bash.bashrc.magcomm ]] ; then
    sudo cp -a /etc/bash.bashrc /etc/bash.bashrc.magcomm
    sudo sed -i '$a #MagcommConfigure'           /etc/bash.bashrc
    sudo sed -i '$a source  /opt/magcomm.conf'   /etc/bash.bashrc
    cp -a $INIT_UTILS_PATH/magcomm.conf /opt/
fi

# 配置VIM和Gitcongig中
echoMe "配置VIM和Gitcongig中..."
#modified by Yar for update vimrc @20171103
cp -a $INIT_UTILS_PATH/vimrc      ~/.vimrc
cp -a $INIT_UTILS_PATH/.gitconfig  ~/
sed -i "s/admin/$USER/g" ~/.gitconfig

# 添加Magcomm工具集
echoMe "添加Magcomm工具集!"
mkdir -p /opt/utils/
cp -a $INIT_UTILS_PATH/toUTF      /opt/utils/
cp -a $INIT_UTILS_PATH/gitssh.sh  /opt/utils/

#安装亿赛通
if [ $INSTALL_ULTRASEC == yes ] ; then
    echoMe "安装亿赛通中..."

#    sudo cp -a $INIT_RESOURCE_PATH/ultrasec-2.8-2b013.deb.bin /usr
#    cd /usr
#    sudo chmod 777 ultrasec-2.8-2b013.deb.bin
#    sudo ./ultrasec-2.8-2b013.deb.bin
    #sudo rm -rf ultrasec-2.8-2b013.deb.bin
    #设置亿赛通需要的内核
#    sudo sed -i 's/default="0"/default="2"/g'  /boot/grub/grub.cfg


#added by Yar for high kernel ultrasec @20171103 begin
    sudo chmod +x $INIT_RESOURCE_PATH/ultrasec/ultrasec_V300R005C09_amd64.deb
    sudo dpkg -i $INIT_RESOURCE_PATH/ultrasec/ultrasec_V300R005C09_amd64.deb
#added by Yar for high kernel ultrasec @20171103 end

    cd $LOCAL_PATH
fi

# 配置 nx
if [[ $INSTALL_NO_MACHINE == "3" ]] ; then
    echoMe "安装NX3.5.0中..."

    sudo cp -a NoMachine/nx_3_5/* /usr/
    cd /usr
    sudo tar zxf nxclient-3.5.0-7.x86_64.tar.gz
    sudo tar zxf nxnode-3.5.0-9.x86_64.tar.gz
    sudo tar zxf nxserver-3.5.0-11.x86_64.tar.gz

    sudo /usr/NX/scripts/setup/nxnode --install
    sudo /usr/NX/scripts/setup/nxserver --install

    old='CommandStartGnome = "/etc/X11/Xsession gnome-session"'
    new='CommandStartGnome = "gnome-session --session=gnome-classic"'
    sudo cp -a /usr/NX/etc/node.cfg /usr/NX/etc/node.cfg.bak

    #sudo sed -i 's#$old#$new#g' /usr/NX/etc/node.cfg

    line=$(sed -n '/CommandStartGnome/=' /usr/NX/etc/node.cfg)
    echo $line
    sudo sed -i "$line s/^/#/"  /usr/NX/etc/node.cfg
    sudo sed -i '/CommandStartGnome/a\CommandStartGnome = "gnome-session --session=gnome-classic"' /usr/NX/etc/node.cfg

    sudo rm -rf nxclient-3.5.0-7.x86_64.tar.gz
    sudo rm -rf nxnode-3.5.0-9.x86_64.tar.gz
    sudo rm -rf nxserver-3.5.0-11.x86_64.tar.gz
    cd $LOCAL_PATH
elif [[ $INSTALL_NO_MACHINE == "4" ]] ; then
    echoMe "安装NX4.5.0_1中..."
    sudo cp -a NoMachine/nx_4_5/* /usr/
    cd /usr
    sudo tar zxf nomachine_4.5.0_1_x86_64.tar.gz
    sudo /usr/NX/nxserver --install
    
    sudo rm -rf nomachine_4.5.0_1_x86_64.tar.gz
    cd $LOCAL_PATH
fi


#配置Samba服务器
if [[ $INSTALL_SAMBA == "yes" ]] ; then
    echoMe "配置Samba服务器中..."

    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

    sudo sed -i '$a #Magcomm Samba' /etc/samba/smb.conf
    sudo sed -i '$a [homes]' /etc/samba/smb.conf
    sudo sed -i '$a comment = home' /etc/samba/smb.conf
    sudo sed -i '$a valid user = %S' /etc/samba/smb.conf
    sudo sed -i '$a writable=yes' /etc/samba/smb.conf
    sudo sed -i '$a browseable=no' /etc/samba/smb.conf
    sudo sed -i '$a create mode = 0664' /etc/samba/smb.conf
    sudo sed -i '$a directory mode = 0775' /etc/samba/smb.conf
    sudo sed -i '$a # Add USER ' /etc/samba/smb.conf
    sudo sed -i '$a [用户名]' /etc/samba/smb.conf
    sudo sed -i '$a path=/home/用户名' /etc/samba/smb.conf
    sudo sed -i '$a available=yes' /etc/samba/smb.conf
    sudo sed -i '$a browseable=yes' /etc/samba/smb.conf
    sudo sed -i '$a public=no' /etc/samba/smb.conf
    sudo sed -i '$a valid user=用户名' /etc/samba/smb.conf
    sudo sed -i '$a writable=yes' /etc/samba/smb.conf

    sudo sed -i "s/用户名/$USER/g" /etc/samba/smb.conf

    echo -e "\e[01;32m*************************************************\e[0m"
    echo -e "\e[01;32m*\e[0m"
    echo -e "\e[01;32m*\e[0m    请输入samba服务器的密码，建议和用户名相同！"
    echo -e "\e[01;32m*\e[0m         \e[01;34m Samba服务器用户名: $USER\e[0m"
    echo -e "\e[01;32m*************************************************\e[0m"
    sudo smbpasswd  -a $USER

fi

#added by Yar for openJDK1.8 @20171103 begin
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install openjdk-8-jdk
#added by Yar for openJDK1.8 @20171103 end
#added by Yar @20180517 begin
sudo apt-get install gawk lib32z1 m4 libxml2-utils curl
#added by Yar @20180517 end

echo -e "\e[01;32m*************************************************\e[0m"
echo -e "\e[01;32m*\e[0m"
echo -e "\e[01;32m*\e[0m   配置完成，请重启！"
echo -e "\e[01;32m*\e[0m"
echo -e "\e[01;32m*\e[0m   友情提示："
echo -e "\e[01;32m*\e[0m       1. SSH密钥配置可以通过工具 gitssh.sh 来快速完成！ "
echo -e "\e[01;32m*\e[0m       2. 重启后亿赛通配置需要先配置 服务器地址：192.168.0.9"
echo -e "\e[01;32m*************************************************\e[0m"

