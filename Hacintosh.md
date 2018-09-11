 ## 安装黑苹果笔记

+ 黑苹果教程地址 https://zhuanlan.zhihu.com/p/36209265

+ 遇到的问题
    + 可以使用通用Clover和HD4400的config.plist进行安装
        + 抹去磁盘会遇到mediakit报空间不足
        因为EFI分区不能小于200mb，在硬盘最后重新压缩出200mb作为新的EFI分区，旧的EFI分区删除分卷
        + 安装时报出OSX10.10被篡改，无法验证
        在终端中输入
        `date 062614102014.30`
    + 驱动配置S1YOGA_10.10EFI进入系统
        + 删掉了原来的声卡驱动、触摸板驱动
        使用万能声卡和触摸板驱动都可以完美运行
        + 删除电池管理驱动
        因为开机电池显示99%，会导致kernel_task cpu loading 25%，发热严重
        重启电池显示为x，不会发热，故删除电池管理驱动
        + 修改了theme
        + 安装小米随身wifi驱动
        使用knext utility把小米随身wifi驱动安装到/S/L/E，并重建缓存
        安装BearExtend后，插入usb wifi就可以用了
        + 硬盘开机Clover引导
        在windows使用EFI工具增加Clover项，接着置顶该项
        用硬盘开机后需要重建小米随身wifi驱动
        + 不完美
        Fn键只能调节音量，不能调节亮度等其他功能
        睡眠后会滴滴响，所以就不睡眠，不能按Fn+F5
        电池电量显示问题

+ 精简office 2016 for mac
`sudo bash -c "curl -s https://raw.githubusercontent.com/goodbest/OfficeThinner/master/OfficeThinner.sh | bash"`