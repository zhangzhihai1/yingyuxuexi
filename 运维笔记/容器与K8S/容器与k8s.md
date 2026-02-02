[TOC]

# 1.docker

## 1.1docker简介

### 1.1.1**使用Docker 容器化封装应用程序的意义**

统一基础设施环境-docker环境

统一程序打包（装箱）方式-docker镜像

统一程序部署（运行）方式-docker容器

![image-20250509110854840](./image-20250509110854840.png)

资源利用率更高:  开销更小,不需要启动单独的虚拟机OS内核占用硬件资源,可以将服务器性能压榨 至极致.虚拟机一般会有5-20%的损耗,容器运行基本无损耗,所以生产中一台物理机只能运行数十个 虚拟机，但是一般可以运行数百个容器 

启动速度更快:  可以在数秒内完成启动 

占用空间更小: 容器一般占用的磁盘空间以MB为单位,而虚拟机以GB 

集成性更好:  和 CI/CD（持续集成/持续部署）相关技术结合性更好，实现打包镜像发布测试可以一 键运行,做到自动化并快速的部署管理,实现高效的开发生命周期

### 1.1.2Namespace

namespace是Linux系统的底层概念，在内核层实现，即有一些不同类型的命名空间被部署在内核，各 个docker容器运行在同一个docker主进程并且共用同一个宿主机系统内核，各docker容器运行在宿主机 的用户空间，每个容器都要有类似于虚拟机一样的相互隔离的运行空间，但是容器技术是在一个进程内 实现运行指定服务的运行环境，并且还可以保护宿主机内核不受其他进程的干扰和影响，如文件系统空间、网络空间、进程空间等，目前主要通过以下技术实现容器运行空间的相互隔离

![image-20250509113537352](./image-20250509113537352.png)

### 1.1.3Control groups

Linux Cgroups的全称是Linux Control Groups,是Linux内核的一个功能.最早是由Google的工程师（主 要是Paul Menage和Rohit Seth）在2006年发起，最早的名称为进程容器（process containers）。在 2007年时，因为在Linux内核中，容器（container）这个名词有许多不同的意义，为避免混乱，被重命 名为cgroup，并且被合并到2.6.24版的内核中去。自那以后，又添加了很多功能。

如果不对一个容器做任何资源限制，则宿主机会允许其占用无限大的内存空间，宿主机有必要对容器进行资 源分配限制，比如CPU、内存等

### 1.1.4Docker 的优势

![image-20250509182804586](./image-20250509182804586.png)

### 1.1.5Docker 的缺点

多个容器共用宿主机的内核，各应用之间的隔离不如虚拟机彻底 

由于和宿主机之间的进程也是隔离的,需要进入容器查看和调试容器内进程等资源,变得比较困难和 繁琐 

如果容器内进程需要查看和调试,需要在每个容器内都需要安装相应的工具,这也造成存储空间的重 复浪费

## 1.2Docker 安装及基础命令介绍

### 1.2.1 Docker 安装

官方网址:   https://www.docker.com/

如果要布署到 kubernetes上，需要查看相关kubernetes对docker版本要求的说明，比如:   https://github.com/kubernetes/kubernetes/blob/v1.17.2/CHANGELOG-1.17.md



官方文档 : https://docs.docker.com/engine/install/ 阿里云文档: https://developer.aliyun.com/mirror/docker-ce?spm=a2c6h.13651102.0.0.3e221b11guHCWE

**Ubuntu 安装和删除Docker**

官方文档:  https://docs.docker.com/install/linux/docker-ce/ubuntu/

```bash
# step 1: 安装必要的一些系统工具
sudo apt-get update
 sudo apt-get -y install apt-transport-https ca-certificates curl software
properties-common
 # step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker
ce/linux/ubuntu $(lsb_release -cs) stable"
 # Step 4: 更新并安装Docker-CE
 sudo apt-get -y update
 sudo apt-get -y install docker-ce

# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
apt-cache madison docker-ce 
docker-ce | 5:19.03.5~3-0~ubuntu-bionic | https://mirrors.aliyun.com/docker-ce/linux/ubuntu bionic/stable amd64 Packages
# Step 2: 安装指定版本的Docker-CE: (VERSION例如上面的5:17.03.1~ce-0~ubuntu-xenial)
sudo apt-get -y install docker-ce=[VERSION] docker-ce-cli=[VERSION]
#示例:指定版本安装
apt-get -y install docker-ce=5:18.09.9~3-0~ubuntu-bionic  docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic

#删除docker
[root@ubuntu ~]#apt purge docker-ce
[root@ubuntu ~]#rm -rf /var/lib/docker
```

内置仓库安装docker

```bash
[root@ubuntu2004 ~]#apt -y install docker.io
[root@ubuntu2004 ~]#docker version
[root@ubuntu2004 ~]#docker info
```

**CentOS 安装和删除Docker**

CentOS 6 因内核太旧，即使支持安装docker，但会有各种问题，不建议安装 CentOS 7 的 extras 源虽然可以安装docker，但包比较旧，建议从官方源或镜像源站点下载安装docker  CentOS 8 有新技术 podman 代替 docker 因此建议在CentOS 7 上安装 docker

官方文档:   https://docs.docker.com/install/linux/docker-ce/centos/

下载rpm包安装:   官方rpm包下载地址: https://download.docker.com/linux/centos/7/x86_64/stable/Packages/ 阿里镜像下载地址:   https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/ 

通过yum源安装:   由于官网的yum源太慢，下面使用阿里云的Yum源进行安装

```bash
#extras 源中包名为docker
[root@centos7 ~]#yum list docker

rm -rf /etc/yum.repos.d/*
#CentOS 7 安装docker依赖三个yum源:Base,Extras,docker-ce
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
wget -O /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum clean all 
yum -y install docker-ce
systemctl enable --now docker

#删除 docker 
[root@centos7 ~]#yum remove docker-ce
 #删除docker资源存放的相关文件
[root@centos7 ~]#rm -rf /var/lib/docker
```

安装指定版本

```bash
[root@rocky8 ~]#cat /etc/yum.repos.d/docker.repo
 [docker-ce]
 name=docker-ce
 baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/8/x86_64/stable/
 gpgcheck=0
[root@rocky8 ~]#yum list docker-ce --showduplicates
[root@rocky8 ~]#yum install docker-ce-3:20.10.10-3.el8 docker-ce-cli-1:20.10.10-3.el8
[root@rocky8 ~]#docker version
[root@rocky8 ~]#systemctl enable --now docker.service
```

**Linux 二进制安装**

二进制安装下载路径 https://download.docker.com/linux/

 https://mirrors.aliyun.com/docker-ce/linux/static/stable/x86_64/

在CentOS8上实现二进制安装docker

```bash
[root@centos8 ~]#wget https://download.docker.com/linux/static/stable/x86_64/docker-19.03.5.tgz

[root@centos8 ~]#tar xvf docker-19.03.5.tgz

#启动dockerd服务
[root@centos8 ~]#dockerd &>/dev/null &

[root@centos8 ~]#docker version
[root@centos8 ~]#docker run hello-world
[root@centos8 ~]#pstree -p

[root@centos8 ~]#cat > /lib/systemd/system/docker.service <<-EOF
 [Unit]
 Description=Docker Application Container Engine
 Documentation=https://docs.docker.com
 After=network-online.target firewalld.service
 Wants=network-online.target
 [Service]
 Type=notify
 # the default is not to use systemd for cgroups because the delegate issues still
 # exists and systemd currently does not support the cgroup feature set required
 # for containers run by docker
 ExecStart=/usr/bin/dockerd -H unix://var/run/docker.sock
 ExecReload=/bin/kill -s HUP \$MAINPID
 # Having non-zero Limit*s causes performance problems due to accounting overhead
 # in the kernel. We recommend using cgroups to do container-local accounting.
 LimitNOFILE=infinity
 LimitNPROC=infinity
 LimitCORE=infinity
 # Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
 #TasksMax=infinity
 TimeoutStartSec=0
 # set delegate yes so that systemd does not reset the cgroups of docker containers
 Delegate=yes
 # kill only the docker process, not all processes in the cgroup
 KillMode=process
 # restart the docker process if it exits prematurely
 Restart=on-failure
 StartLimitBurst=3
 StartLimitInterval=60s
 [Install]
 WantedBy=multi-user.target
 EOF
 
 [root@centos8 ~]#systemctl daemon-reload
 [root@centos8 ~]#systemctl enable --now docker
```

#### 一键离线安装二进制 docker

```bash
#!/bin/bash
DOCKER_VERSION=20.10.10
URL=https://mirrors.aliyun.com
prepare () {
    if [ ! -e docker-${DOCKER_VERSION}.tgz ];then
        wget ${URL}/docker-ce/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz
    fi
    [ $? -ne 0  ] && { echo "文件下载失败"; exit; }
}
install_docker () {
    tar xf docker-${DOCKER_VERSION}.tgz -C /usr/local/
 cp /usr/local/docker/* /usr/bin/
 cat > /lib/systemd/system/docker.service <<-EOF
 [Unit]
 Description=Docker Application Container Engine
 Documentation=https://docs.docker.com
 After=network-online.target firewalld.service
 Wants=network-online.target
 [Service]
 Type=notify
 # the default is not to use systemd for cgroups because the delegate issues 
still
 # exists and systemd currently does not support the cgroup feature set required
 # for containers run by docker
 ExecStart=/usr/bin/dockerd -H unix://var/run/docker.sock
 ExecReload=/bin/kill -s HUP \$MAINPID
 # Having non-zero Limit*s causes performance problems due to accounting overhead
 # in the kernel. We recommend using cgroups to do container-local accounting.
 LimitNOFILE=infinity
 LimitNPROC=infinity
 LimitCORE=infinity
 # Uncomment TasksMax if your systemd version supports it.
 # Only systemd 226 and above support this version.
 #TasksMax=infinity
 TimeoutStartSec=0
 # set delegate yes so that systemd does not reset the cgroups of docker 
containers
 Delegate=yes
 # kill only the docker process, not all processes in the cgroup
 KillMode=process
 # restart the docker process if it exits prematurely
 Restart=on-failure
 StartLimitBurst=3
 StartLimitInterval=60s
 [Install]
 WantedBy=multi-user.target
 EOF
     systemctl daemon-reload
 }
 start_docker (){
    systemctl enable --now docker
    docker version
 }
 prepare
 install_docker
 start_docker
```

#### CentOS8上安装 podman

```bash
#在CentOS8上安装docker会自动安装podman,docker工具只是一个脚本，调用了Podman
 [root@centos8 ~]#dnf install docker
 [root@centos8 ~]#rpm -ql podman-docker
 /usr/bin/docker
 [root@centos8 ~]#cat /usr/bin/docker
 [root@centos8 ~]#podman version
  #修改拉取镜像的地址的顺序，提高速度
[root@centos8 ~]#vim /etc/containers/registries.conf
 [registries.search]
 registries = ['docker.io'，'quay.io'，'registry.redhat.io', 
'registry.access.redhat.com']
```

#### 在不同系统上实现一键安装 docker 脚本

#### 通用安装Docker脚本

从Docker官方下载通用安装脚本

```bash
[root@ubuntu1804 ~]#curl -fsSL get.docker.com -o get-docker.sh
[root@ubuntu1804 ~]#sh get-docker.sh --mirror Aliyun
```

### 1.2.2Docker 程序环境

环境配置文件

```bash
/etc/sysconfig/docker-network
/etc/sysconfig/docker-storage
/etc/sysconfig/docker
```

Unit File

```bash
/usr/lib/systemd/system/docker.service
```

 docker-ce 配置文件

```bash
/etc/docker/daemon.json
```

Docker Registry配置文件:

```bash
/etc/containers/registries.conf
```

ubuntu 查看docker相关文件

```bash
#服务器端相关文件
[root@ubuntu1804 ~]#dpkg -L docker-ce
 #客户端相关文件
[root@ubuntu1804 ~]#dpkg -L docker-ce-cli
```

CentOS7 查看docker相关文件

```bash
[root@centos7 ~]#rpm -ql docker-ce
[root@centos7 ~]#rpm -ql docker-ce-cli
```

### 1.2.3Docker 命令

帮助

```bash
#docker 命令帮助
man docker 
docker
docker  --help
#docker  子命令帮助
man docker-COMMAND
docker COMMAND --help
```

```bash
#查看 docker 版本
[root@ubuntu1804 ~]#docker version
#查看 docker 详解信息
[root@ubuntu1804 ~]#docker info
 WARNING: No swap limit support  #系统警告信息 (没有开启 swap 资源限制 )
范例: 解决上述SWAP报警提示
范例: 解决上述SWAP报警提示
官方文档:  
https://docs.docker.com/install/linux/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities

[root@ubuntu1804 ~]# vim /etc/default/grub
 GRUB_DEFAULT=0
 GRUB_TIMEOUT_STYLE=hidden
 GRUB_TIMEOUT=2
 GRUB_DISTRIBUTOR=`lsb_ release -i -s 2> /dev/null || echo Debian`
 GRUB_CMDLINE_LINUX_DEFAULT=""
 GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 swapaccount=1"  #修改此行
 [root@ubuntu1804 ~]# update-grub
 [root@ubuntu1804 ~]# reboot
```

#### Docker 优化

```bash
[root@ubuntu2004 ~]#vim /etc/docker/daemon.json
 {
 "registry-mirrors": [
 "https://registry.docker-cn.com",
 "http://hub-mirror.c.163.com",
 "https://docker.mirrors.ustc.edu.cn"
  ],
 "insecure-registries": ["harbor.wang.org"],
 "exec-opts": ["native.cgroupdriver=systemd"],
 "graph": "/data/docker",  #指定docker数据目录
"max-concurrent-downloads": 10,
 "max-concurrent-uploads": 5,
 "log-opts": {
 "max-size": "300m",
 "max-file": "2"
 },
 "live-restore": true
 }
 [root@ubuntu2004 ~]#systemctl daemon-reload ;systemctl restart docker.service
```

**查看 docker0 网卡**

在docker安装启动之后，默认会生成一个名称为docker0的网卡并且默认IP地址为172.17.0.1的网卡

```bash
#ubuntu18.04安装docker后网卡配置
[root@ubuntu1804 ~]#ip a
```

**docker 存储引擎**

#### 镜像管理

```bash
[root@ubuntu1804 ~]#docker pull nginx 
 #查看镜像分层历史
[root@ubuntu1804 ~]#docker image  history nginx

[root@ubuntu1804 ~]#docker inspect nginx
#镜像导出
[root@ubuntu1804 ~]#docker save nginx -o nginx.tar

[root@ubuntu1804 ~]#docker images
[root@ubuntu1804 ~]#ll -h nginx.tar 
[root@ubuntu1804 ~]#tar xf nginx.tar  -C /data
[root@ubuntu1804 ~]#ll /data
```



```bash
#搜索镜像
[root@ubuntu1804 ~]#docker search centos

#下载镜像
docker pull

#镜像下载保存的路径:  
/var/lib/docker/overlay2/镜像ID

#查看本地镜像
docker images

#只查看指定REPOSITORY的镜像
[root@ubuntu1804 ~]#docker images tomcat

#查看指定镜像的详细信息
[root@centos8 ~]#podman image inspect alpine

root@ubuntu1804 ~]#docker save mysql:5.7.30 alpine:3.11.3 -o /data/myimages.tar

#导出所有镜像至不同的文件中
[root@centos8 ~]#docker images | awk 'NR!=1{print $1,$2}' | while read repo tag ;do docker save   $repo:$tag -o /opt/$repo-$tag.tar ;done
[root@centos8 ~]#ls /opt/*.tar

# 镜像打标签
docker tag

常用总结：
docker search centos
docker pull alpine
docker images
docker save > /opt/centos.tar #centos #导出镜像
docker load -i /opt/centos.tar  #导入本地镜像
docker rmi 镜像ID/镜像名称  #删除指定ID的镜像，此镜像对应容器正启动镜像不能被删除，除非将容器全部关闭
```

导出所有镜像到一个打包文件

```bash
#方法1: 使用image ID导出镜像,在导入后的镜像没有REPOSITORY和TAG,显示为<none>
 [root@ubuntu1804 ~]#docker save `docker images -qa` -o all.tar
 #方法2:将所有镜像导入到一个文件中,此方法导入后可以看REPOSITORY和TAG
 [root@ubuntu1804 ~]#docker save `docker images | awk 'NR!=1{print $1":"$2}'` -o  all.tar
 #方法3:将所有镜像导入到一个文件中,此方法导入后可以看REPOSITORY和TAG
 [root@centos8 ~]#docker image save `docker image ls --format "{{.Repository}}:{{.Tag}}"` -o all.tar
```

镜像导入

```bash
docker load
docker load -i /path/file.tar
docker load < /path/file.tar

#一次导入多个镜像
[root@ubuntu1804 ~]#docker save busybox alpine > /all.tar
[root@ubuntu1804 ~]#ll -h /opt/all.tar

[root@ubuntu1804 ~]#docker rmi -f `docker images -q` #-q只显示id
[root@ubuntu1804 ~]#docker load -i /opt/all.tar
[root@ubuntu1804 ~]#docker images
```



**镜像加速配置和优化**

```bash
docker 镜像官方的下载站点是:  
https://hub.docker.com/
```

**1 阿里云获取加速地址**

![image-20250510164754563](./image-20250510164754563.png)

```bash
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
 {
 "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn","http://hub-mirror.c.163.com/","https://si7y70hh.mirror.aliyuncs.com"],
 "live-restore": true, #docker服务重启,不会重启容器,
 "graph": "/data/docker"，  #指定docker数据目录
"insecure-registries": ["harbor.wang.org"]
 }
 EOF
systemctl daemon-reload
 systemctl restart docker
 systemctl daemon-reload
 systemctl restart docker
```

阿里云已经做了限制

1. **仅限阿里云用户在具备公网访问的阿里云产品上使用该镜像加速能力。**
2. **仅支持通过镜像加速器拉取限定范围内的容器镜像。**







#### alpine介绍

Alpine Docker 镜像也继承了 Alpine Linux 发行版的这些优势。相比于其他 Docker 镜像，它的容量非 常小，仅仅只有 5 MB 左右（对比 Ubuntu 系列镜像接近 200 MB），且拥有非常友好的包管理机制。 官方镜像来自 docker-alpine 项目。

目前 Docker 官方已开始**推荐使用 Alpine 替代之前的 Ubuntu 做为基础镜像环境**。这样会带来多个好 处。包括镜像下载速度加快，镜像安全性提高，主机之间的切换更方便，占用更少磁盘空间等。

Alpine 官网:   https://www.alpinelinux.org/ Alpine 官方仓库:   Alpine 官方镜像:   https://github.com/alpinelinux Alpine 官方镜像仓库:   https://hub.docker.com/_/alpine/ Alpine 阿里云的镜像仓库:   https://github.com/gliderlabs/docker-alpine https://mirrors.aliyun.com/alpine/

alpine管理软件

```bash
#修改源替换成阿里源，将里面 dl-cdn.alpinelinux.org 的 改成 mirrors.aliyun.com
 vi /etc/apk/repositories
 http://mirrors.aliyun.com/alpine/v3.8/main/
 http://mirrors.aliyun.com/alpine/v3.8/community/

#更新源
apk update
 #安装软件
apk add vim
 #删除软件
apk del openssh openntp vim

/ # apk --help
/ # apk add  nginx
/ # apk info nginx
~ # apk manifest nginx
```

Debian(ubuntu)系统建议安装的基础包

在很多软件官方提供的镜像都使用的是Debian(ubuntu)的系统,比如:nginx,tomcat,mysql,httpd 等,但镜 像内缺少很多常用的调试工具.当需要进入容器内进行调试管理时,可以安装以下常用工具包

```bash
# apt update            #安装软件前需要先更新索引    
# apt install procps        #提供top,ps,free等命令
# apt install psmisc        #提供pstree,killall等命令
# apt install iputils-ping  #提供ping命令
# apt install net-tools     #提供netstat网络工具等
```

### 1.2.4容器操作基础命令

```bash
#相关命令
[root@ubuntu1804 ~]#docker container
```

##### 启动容器

```bash
#启动容器
[root@centos8 ~]# docker run hello-world
[root@centos8 ~]#docker ps -a

#一次性运行容器中命令
#启动的容器在执行完shell命令就退出，用于测试
[root@ubuntu1804 ~]#docker run  busybox echo "Hello laowang"

#运行交互式容器并退出
[root@ubuntu1804 ~]#docker run -it docker.io/busybox  sh
/ # exit

#用exit退出后容器也停止
[root@ubuntu1804 ~]#docker ps -l

#用同时按三个键ctrl+p+q退出后容器不会停止
```

设置容器内的主机名

```bash
[root@ubuntu1804 ~]#docker run -it --name a1 -h a1.wang.org alpine
/ # hostname
/ # cat /etc/hosts

#一次性运行容器，退出后立即删除，用于测试
[root@ubuntu1804 ~]#docker run  --rm  alpine cat /etc/issue
[root@ubuntu1804 ~]#docker ps -a
```

**守护式容器**

```bash
#启动前台守护式容器
[root@ubuntu1804 ~]#docker run --rm --name b1 busybox  wget -qO - 172.17.0.3

#启动后台守护式容器
[root@ubuntu1804 ~]#docker run -d nginx

#有些容器后台启动不会持续运行
[root@ubuntu1804 ~]#docker run -d --name alpine4 alpine
```

 开机自动运行容器

```bash
#设置容器总是运行
[root@ubuntu1804 ~]#docker run -d --name nginx --restart=always -p 80:80  nginx
```

-**-privileged 选项**

使用该参数，container内的root拥有真正的root权限。  否则，container内的root只是外部的一个普通用户权限。privileged启动的容器，可以看到很多host上 的设备，并且可以执行mount。甚至允许你在docker容器中启动docker容器。

##### 查看容器信息

```bash
#显示运行的容器
[root@ubuntu1804 ~]#docker ps 
[root@ubuntu1804 ~]#docker ps  -a
#显示容器大小
[root@ubuntu1804 ~]#docker ps  -a -s

#显示最新创建的容器(停止的容器也能显示)
[root@ubuntu1804 ~]#docker ps  -l

 #查看退出状态的容器
[root@ubuntu1804 ~]#docker ps  -f 'status=exited'
```

查看容器内的进程

```bash
[root@ubuntu1804 ~]#docker run -d  httpd
[root@ubuntu1804 ~]#docker top db144f19
```

**查看容器资源使用情况**

```bash
[root@ubuntu1804 ~]#docker stats
[root@ubuntu1804 ~]#docker stats 251c7c7cf2aa

 #限制内存使用大小
[root@ubuntu1804 ~]#docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx128m" elasticsearch:7.6.2
```

**查看容器的详细信息**

docker inspect 可以查看docker各种对象的详细信息,包括:镜像,容器,网络等



##### 删除容器

```bash
docker rm

#删除所有停止的容器
[root@ubuntu1804 ~]#docker container prune  -f 
```

##### 容器的启动和停止

```bash
docker start|stop|restart|pause|unpause 容器ID

#启动并进入容器
[root@ubuntu1804 ~]#docker start -i c1
```

##### 给正在运行的容器发信号

```bash
docker kill  可以给容器发信号,默认号SIGKILL,即9信号

#强制关闭所有运行中的容器
[root@ubuntu1804 ~]#docker  kill `docker ps -a -q`
```

##### 进入正在运行的容器

```bash
docker attach 容器名
```

attach 类似于vnc，操作会在同一个容器的多个会话界面同步显示，所有使用此 方式进入容器的操作都是同步显示的，且使用exit退出后容器自动关闭，**不推荐使用**，需要进入到有 shell环境的容器

**使用exec命令**

```bash
 #常见用法
docker exec -it 容器ID sh|bash

#执行一次性命令
[root@ubuntu1804 ~]#docker exec 2478 cat /etc/redhat-release

#进入容器，执行命令，exit退出但容器不停止
[root@ubuntu1804 ~]#docker exec  -it 2478  bash
```

##### 暴露所有容器端口

容器启动后,默认处于预定义的NAT网络中,所以外部网络的主机无法直接访问容器中网络服务

```bash
docker run -P docker.io/nginx  #映射容器所有暴露端口至随机本地端口，注意是随机
docker port 可以查看容器的端口映射关系
```

端口映射的本质就是利用NAT技术实现的

```bash
#对比端口映射前后的变化
[root@ubuntu1804 ~]#iptables -S > post.filter
[root@ubuntu1804 ~]#iptables -S -t nat > post.nat
[root@ubuntu1804 ~]#diff pre.filter post.filter
```

##### 指定端口映射

```bash
docker run  -p 8080:80/tcp -p 8443:443/tcp -p 53:53/udp --name nginx-test-port6  
nginx
```

修改已经创建的容器的端口映射关系

```bash
[root@ubuntu1804 ~]#docker run -d -p 80:80 --name nginx01 nginx
[root@ubuntu1804 ~]#docker port nginx01
[root@ubuntu1804 ~]#lsof -i:80

[root@ubuntu1804 ~]#ls /var/lib/docker/containers/dc5d7c1029e582a3e05890fd18565367482232c151bba09ca27e195d39dbcc24/

[root@ubuntu1804 ~]#systemctl stop docker

[root@ubuntu1804 ~]#vim /var/lib/docker/containers/dc5d7c1029e582a3e05890fd18565367482232c151bba09ca27e195d39dbcc24/hostconfig.json
"PortBindings":{"80/tcp":[{"HostIp":"","HostPort":"80"}]} 
#PortBindings后80/tcp对应的是容器内部的80端口，HostPort对应的是映射到宿主机的端口80 修改此处为8000
[root@ubuntu1804 ~]#systemctl start docker
[root@ubuntu1804 ~]#docker start nginx01
[root@ubuntu1804 ~]#docker port nginx01
```

实现 wordpress 应用

```bash
[root@ubuntu2004 ~]#docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e  MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=123456 --name  mysql -d  --restart=always mysql:8.0.29-oracle

[root@ubuntu2004 ~]#docker run -d -p 8080:80 --name wordpress -v /data/wordpess:/var/www/html --restart=always  wordpress:php7.4-apache
```

##### 查看容器的日志

```bash
[root@ubuntu1804 ~]#docker run  alpine /bin/sh -c 'i=1;while true;do echo hello$i;let i++;sleep 2;done'

[root@ubuntu1804 ~]#docker logs --tail 3 5126

 #显示时间
[root@ubuntu1804 ~]#docker logs --tail 0 -t 5126
 2020-02-25T13:30:07.321390731Z hello17
 
 #持续跟踪
[root@ubuntu1804 ~]#docker logs -f 5126


#查看httpd服务日志
[root@ubuntu1804 ~]#docker run -d -p 80:80 --name web1  httpd
[root@ubuntu1804 ~]#docker logs web1
```

##### 传递运行命令

**不重要**

容器需要有一个前台运行的进程才能保持容器的运行，通过传递运行参数是一种方式，另外也可以在构 建镜像的时候指定容器启动时运行的前台命令

服务类:  如:  Nginx，Tomcat，Apache ，但服务不能停 命令类:  如:  tail -f  /etc/hosts ，主要用于测试环境

```bash
[root@ubuntu1804 ~]#docker run -d alpine tail -f /etc/hosts
```

##### 容器内部的hosts文件

容器会自动将容器的ID加入自已的/etc/hosts文件中，并解析成容器的IP

```bash
 [root@ubuntu1804 ~]#docker run -it centos /bin/bash
 [root@598262a87c46 /]# cat /etc/hosts
```

修改容器的 hosts文件

```bash
[root@ubuntu1804 ~]#docker run -it --rm --add-host www.wangxiaochun.com:6.6.6.6 --add-host www.wang.org:8.8.8.8   busybox
```

**指定容器DNS**

**不重要**

容器的dns服务器，**默认采用宿主机的dns 地址**，可以用下面方式指定其它的DNS地址

在容器启动时加选项 --dns=x.x.x.x 在/etc/docker/daemon.json 文件中指定

##### **容器内和宿主机之间复制文件**

```bash
[root@ubuntu2004 ~]#docker run -it --name b1  busybox sh
[root@ubuntu2004 ~]#docker cp  b1:/bin/busybox /usr/local/bin/
[root@ubuntu2004 ~]#busybox ls

#将宿主机文件复制到容器内
[root@ubuntu1804 ~]#docker cp /etc/issue  1311:/root/
[root@ubuntu1804 ~]#docker exec 1311 cat /root/issue
```

##### 使用 systemd 控制容器运行

```bash
[root@ubuntu1804 ~]#cat  /lib/systemd/system/hello.service
 [Unit] 
Description=Hello World 
After=docker.service 
Requires=docker.service 
[Service] 
TimeoutStartSec=0 
ExecStartPre=-/usr/bin/docker kill busybox-hello
 ExecStartPre=-/usr/bin/docker rm busybox-hello
 ExecStartPre=/usr/bin/docker pull busybox
 ExecStart=/usr/bin/docker run --name busybox-hello busybox /bin/sh -c "while true; do echo Hello World; sleep 1; done" 
ExecStop=/usr/bin/docker kill busybox-hello
 [Install] 
WantedBy=multi-user.target
 [root@ubuntu1804 ~]#systemctl  daemon-reload 
[root@ubuntu1804 ~]#systemctl  enable --now hello.service 

```

##### 传递环境变量

```bash
[root@ubuntu1804 ~]#docker run --name mysql-test1 -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wpuser -e MYSQL_PASSWORD=123456 -d -p 3306:3306 mysql:5.7.30

[root@ubuntu1804 ~]#docker run --name mysql-test2 -v /root/mysql/:/etc/mysql/conf.d -v /data/mysql2:/var/lib/mysql --env-file=env.list -d -p 3307:3306 mysql:5.7.3
```

### 1.2.5实战案例: 利用 docker 快速部署自动化运维平台

Spug 面向中小型企业设计的轻量级无 Agent 的自动化运维平台，整合了主机管理、主机批量执行、主 机在线终端、文件在线上传下载、应用发布部署、在线任务计划、配置中心、监控、报警等一系列功能

官网地址:  https://www.spug.dev/ 

使用文档： https://www.spug.dev/docs/about-spug/ 

gitee链接:   https://gitee.com/openspug/spug

```bash
官方说明
https://www.spug.dev/docs/install-docker/
```



```bash
#拉取镜像
[root@ubuntu1804 ~]# docker pull registry.aliyuncs.com/openspug/spug
[root@ubuntu1804 ~]#docker run -d --restart=always --name=spug -p 80:80 
registry.aliyuncs.com/openspug/spug
$ docker run -d --restart=always --name=spug -p 80:80 -v /mydata/:/data 
registry.aliyuncs.com/openspug/spug
# 持久化存储启动命令：
# mydata指的是本地磁盘路径，也可以是其他目录，但需要保证映射的本地磁盘路径已经存在，/data是容器内代码和数据初始化存储的路径

#初始化
[root@ubuntu1804 ~]#docker exec spug init_spug admin 123456
```

## 1.3镜像制作与管理

### 1.3.1Docker 镜像中有没有内核

镜像里 面是没有内核的，镜像在被启动为容器后将直接使用宿主机的内核，而镜像本身则只提供相应的 rootfs，即系统正常运行所必须的用户空间的文件系统，容器 当中/boot目录是空的，而/boot当中保存的就是与内核相关的文件和目录。

**为什么没有内核**

由于容器启动和运行过程中是直接使用了宿主机的内核，不会直接调用物理硬件，所以也不会涉及到硬 件驱动，因此也无需容器内拥有自已的内核和驱动。而如果使用虚拟机技术，对应每个虚拟机都有自已 独立的内核

### 1.3.2将现有容器通过 docker commit 手动构建镜像

![image-20250510191400508](./image-20250510191400508.png)

```bash
[root@ubuntu1804 ~]#docker commit -a "wang<root@wangxiaochun.com>" -c 'CMD /bin/httpd -fv -h /data/html' -c "EXPOSE 80" b1 httpd-busybox:v1.0
```

### 1.3.3利用 DockerFile 文件执行 docker build 自动构建镜 像

DockerFile 是一种被Docker程序解释执行的脚本，由一条条的命令组成的

#### Dockerfile 相关指令

```bash
FROM: 指定基础镜像
LABEL: 指定镜像元数据 #可以指定镜像元数据，如:  镜像作者等

RUN: 执行 shell命令 #注意:  RUN 可以写多个，每一个RUN指令都会建立一个镜像层，所以尽可能合并成一条指令,比如将多个shell命令通过 && 连接一起成为在一条指令
ENV: 设置环境变量  #
ARG: 构建参数  #ARG指令在build 阶段指定变量,和ENV不同的是，容器运行时不会存在这些环境变量，如果和ENV同名，ENV覆盖ARG变量，如ARG author="wang <root@wangxiaochun.com>" LABEL maintainer="${author}"

COPY: 复制文本   #复制本地宿主机的 到容器中的 。
ADD: 复制和解包文件  #该命令可认为是增强版的COPY，不仅支持COPY，还支持自动解压缩。

CMD: 容器启动命令   #一个容器中需要持续运行的进程一般只有一个,CMD 用来指定启动容器时默认执行的一个命令，且其运行结束后,容器也会停止,所以一般CMD 指定的命令为持续运行且为前台命令.
ENTRYPOINT: 入口点  #功能类似于CMD，配置容器启动后执行的命令及参数

VOLUME: 匿名卷   #在容器中创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保持的数据等，默认会将宿主机上的目录挂载至VOLUME 指令指定的容器目录。即使容器后期被删除，此宿主机的目录仍会保留，从而实现容器数据的持久保存。
#VOLUME ["<容器内路径1>", "<容器内路径2>"...]无法指定宿主机路径和容器目录的挂载关系
#通过docker rm -fv <容器ID> 可以删除容器的同时删除VOLUME指定的卷

EXPOSE: 暴露端口  #即使 Dockerfile 没有 EXPOSE 端口指令,也可以通过docker run -p  临时暴露容器内程序真正监听的端口,所以EXPOSE 相当于指定默认的暴露端口,可以通过docker run -P 进行真正暴露

WORKDIR: 指定工作目录  #为后续的 RUN、CMD、ENTRYPOINT 指令配置工作目录，当容器运行后，进入容器内WORKDIR指定的默认目录

ONBUILD: 子镜像引用父镜像的指令   #可以用来配置当构建当前镜像的子镜像时，会自动触发执行的指令,但在当前镜像构建时,并不会执行,即延迟到子镜像构建时才执行

USER: 指定当前用户
HEALTHCHECK: 健康检查
```

**cmd与entrypoint**

**cmd**

如果docker run没有指定任何的执行命令或者dockerfile里面也没有ENTRYPOINT命令，那么开启 容器时就会使用执行CMD指定的默认的命令

每个 Dockerfile 只能有一条 CMD 命令。如指定了多条，只有最后一条被执行

如果用户启动容器时用 docker run xxx 指定运行的命令，则会覆盖 CMD 指定的命令

**entrypoint**

ENTRYPOINT 不能被 docker run 提供的参数覆盖，而是追加,即如果docker run 命令有参数，那 么参数全部都会作为ENTRYPOINT的参数

Dockerfile中即有CMD也有ENTRYPOINT,那么CMD的全部内容会作为ENTRYPOINT的参 数

每个 Dockerfile 中只能有一个 ENTRYPOINT，当指定多个时，只有最后一个生效

**即三个都存在时docker run 参数覆盖cmd参数最终作为entrypoint参数**

**ONBUILD**

![image-20250510215445372](./image-20250510215445372.png)

```bash
[root@centos8 ~]#cat /data/dockerfile/web/nginx/nginx-1.18/Dockerfile
FROM centos:centos7.9-v10.0
LABEL maintainer="wangxiaochun <root@wangxiaochun.com>" 
ENV version=1.18.0
ADD nginx-$version.tar.gz /usr/local/
RUN cd /usr/local/nginx-$version && ./configure --prefix=/apps/nginx && make && make install && rm -rf /usr/local/nginx* && sed -i 's/.*nobody.*/user nginx;/'  
/apps/nginx/conf/nginx.conf && useradd -r nginx
COPY index.html /apps/nginx/html
VOLUME ["/apps/nginx/html"]
EXPOSE 80 443
CMD ["-g","daemon off;"]
ENTRYPOINT ["/apps/nginx/sbin/nginx"]
#上面两条指令相当于ENTRYPOINT ["/apps/nginx/sbin/nginx","-g","daemon off;"]
HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://127.0.0.1/


[root@ubuntu1804 dockerfile]#cat Dockerfile
 FROM ubuntu:18.04
 RUN apt update \
 && apt -y install  curl \
 && rm -rf /var/lib/apt/lists/*
 ENTRYPOINT [ "curl", "-s","https://ip.cn"]
```

##### 利用脚本实现指定环境变量动态生成配置文件内容

```bash
[root@ubuntu1804 ~]#echo 'Nginx Website in Dockerfile' > index.html
 [root@ubuntu1804 ~]#cat Dockerfile
 FROM nginx:1.16-alpine
 LABEL maintainer="wangxiaochun <root@wangxiaochun.com>"
 ENV DOC_ROOT='/data/website/'
 ADD index.html ${DOC_ROOT}
 ADD entrypoint.sh /bin/
 EXPOSE 80/tcp 8080
 #HEALTHCHECK --start-period=3s CMD wget -0 - -q http://${IP:-0.0.0.0}:
 {PORT:-80}/
 CMD ["/usr/sbin/nginx","-g", "daemon off;"]  #CMD指令的内容都成为了ENTRYPOINT的参数
ENTRYPOINT [ "/bin/entrypoint.sh"]
[root@ubuntu1804 ~]#cat entrypoint.sh
#!/bin/sh 
cat > /etc/nginx/conf.d/www.conf <<EOF
server {
    server_name ${HOSTNAME};
    listen ${IP:-0.0.0.0}:${PORT:-80};
    root   
${DOC_ROOT:-/usr/share/nginx/html};
}
EOF
exec "$@"
[root@ubuntu1804 ~]#chmod +x entrypoint.sh
[root@ubuntu1804 ~]#docker build -t nginx:v1.0 . 
[root@ubuntu1804 ~]#docker run --name n1 --rm -P -e "PORT=8080" -e 
"HOSTNAME=www.wang.org" nginx:v1.0
```

##### 构建镜像docker build 命令

```bash
[root@ubuntu1804 ~]#cat /data/Dockerfile 
[root@ubuntu1804 ~]#docker build -t nginx_centos8.2:v1.14.1 /data/
```

#### 实战案例

##### Dockerfile 制作基于基础镜像的Base镜像

1 准备目录结构，下载镜像并初始化系统

```bash
[root@ubuntu1804 ~]#mkdir /data/dockerfile/{web/{nginx,apache,tomcat,jdk},system/{centos,ubuntu,alpine,debian}} -p

#下载基础镜像
[root@ubuntu1804 ~]#docker pull centos:centos7.7.1908
[root@ubuntu1804 ~]#docker images
```

2 先制作基于基础镜像的系统Base镜像

```bash
#先制作基于基础镜像的系统base镜像
[root@ubuntu1804 ~]#cd /data/dockerfile/system/centos/
 #创建Dockerfile，注意可以是dockerfile，但无语法着色功能
[root@ubuntu1804 centos]#vim Dockerfile
[root@ubuntu1804 centos]#cat Dockerfile
FROM centos:centos7.7.1908
LABEL maintainer="wangxiaochun <root@wangxiaochun.com>"      
RUN yum -y install wget && rm -f /etc/yum.repos.d/* && wget -P /etc/yum.repos.d/ 
http://mirrors.aliyun.com/repo/Centos-7.repo \ 
    &&wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo \
    &&sed -i -e  '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/Centos-7.repo \
    && yum -y install  vim-enhanced tcpdump lrzsz tree telnet bash-completion net-tools wget curl bzip2 lsof  zip unzip nfs-utils gcc make gcc-c++ glibc glibc-devel pcre pcre-devel openssl  openssl-devel systemd-devel zlib-devel \
    && yum clean all \
    && rm -f /etc/localtime  \
    && ln -s ../usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

```bash
[root@ubuntu1804 centos]#vim build.sh
 [root@ubuntu1804 centos]#cat build.sh
 #!/bin/bash
 #
docker build -t centos7-base:v1  .
[root@ubuntu1804 centos]#chmod +x build.sh
[root@ubuntu1804 centos]#./build.sh 
[root@ubuntu1804 centos]#docker images
[root@ubuntu1804 centos]#docker image history centos7-base:v1
```

##### Dockerfile 制作基于Base镜像的 nginx 镜像

1在Dockerfile目录下准备编译安装的相关文件

```bash
[root@ubuntu1804 ~]#mkdir /data/dockerfile/web/nginx/1.16
 [root@ubuntu1804 ~]#cd /data/dockerfile/web/nginx/1.16
 [root@ubuntu1804 1.16]#wget http://nginx.org/download/nginx-1.16.1.tar.gz
 [root@ubuntu1804 1.16]#mkdir app/
 [root@ubuntu1804 1.16]#echo  "Test Page in app" > app/index.html
 [root@ubuntu1804 1.16]#tar zcf app.tar.gz app
 [root@ubuntu1804 1.16]#ls
 app  app.tar.gz nginx-1.16.1.tar.gz 
```

2 在一台测试机进行编译安装同一版本的nginx 生成模版配置文件

```bash
[root@centos7 ~]#yum -y install vim-enhanced tcpdump lrzsz tree telnet bash completion net-tools wget bzip2 lsof tmux man-pages zip unzip nfs-utils gcc make gcc-c++ glibc glibc-devel pcre pcre-devel openssl  openssl-devel systemd-devel zlib-devel
 [root@centos7 ~]#wget -P /usr/local/src http://nginx.org/download/nginx-1.16.1.tar.gz
 [root@centos7 ~]#cd /usr/local/src/
 [root@centos7 src]#tar xvf nginx-1.16.1.tar.gz 
[root@centos7 src]#cd nginx-1.16.1/
 [root@centos7 nginx-1.16.1]#./configure  --prefix=/apps/nginx && make && make install 
#将配置文件复制到nginx镜像的服务器相应目录下
[root@centos7 ~]#scp /apps/nginx/conf/nginx.conf 10.0.0.100:/data/dockerfile/web/nginx/1.16 
#准备配置文件
[root@ubuntu1804 1.16]#vim /data/dockerfile/web/nginx/1.16/nginx.conf
 worker_processes  1;
 user nginx;
 daemon off;   #增加此行,前台运行nginx
```

3 编写Dockerfile文件

```bash
[root@ubuntu1804 ~]#cd /data/dockerfile/web/nginx
 [root@ubuntu1804 nginx]#vim  Dockerfile 
[root@ubuntu1804 nginx]#cat Dockerfile 
FROM centos7-base:v1
 LABEL maintainer="wangxiaochun <root@wangxiaochun.com>"
 ADD nginx-1.16.1.tar.gz /usr/local/src
 RUN cd /usr/local/src/nginx-1.16.1 && \
    && ./configure --prefix=/apps/nginx \
    && make && make install \
    && rm -f /usr/local/src/nginx* \
    && useradd -r nginx
COPY nginx.conf /apps/nginx/conf/
ADD  app.tar.gz /apps/nginx/html/
EXPOSE 80 443
CMD ["/apps/nginx/sbin/nginx"]
```

4 生成nginx镜像

```bash
[root@ubuntu1804 ~]#cd /data/dockerfile/web/nginx/1.16
[root@ubuntu1804 1.16]#ls
 app  app.tar.gz  build.sh  Dockerfile  nginx-1.16.1.tar.gz  nginx.conf
 [root@ubuntu1804 1.16]#vim build.sh
 [root@ubuntu1804 1.16]#cat build.sh
 #!/bin/bash
 #
 docker build -t nginx-centos7:1.6.1 . 
[root@ubuntu1804 1.16]#chmod +x build.sh
 [root@ubuntu1804 1.16]#./build.sh 
[root@ubuntu1804 1.16]##docker images
```

5 生成的容器测试镜像

```bash
[root@ubuntu1804 ~]#docker run  -d -p 80:80  nginx-centos7:1.6.1
[root@ubuntu1804 ~]#docker ps
[root@ubuntu1804 ~]#docker exec -it e8e733c6dc96 bash
[root@e8e733c6dc96 /]# ps aux
[root@ubuntu1804 ~]#curl 127.0.0.1/app/
```

##### Dockerfile 直接制作 nginx 镜像

##### 多阶段构建

利用多阶段构建,可以大大减小镜像的大小,但要注意相关依赖文件都要复制到新构建中才能正常运行容器

```bash
[root@ubuntu2004 go-hello]#cat hello.go 
[root@ubuntu2004 go-hello]#cat build.sh
docker build -t go-hello:$1 .

[root@ubuntu2004 go]#cat Dockerfile
FROM golang:1.18-alpine
COPY hello.go /opt
WORKDIR /opt
RUN go build hello.go 
CMD "./hello"

[root@ubuntu2004 go-hello]#bash build.sh v1.0
[root@ubuntu2004 go-hello]#docker run --name hello go-hello:v1.0
 hello, world
 
 [root@ubuntu2004 go-hello]#cp Dockerfile Dockerfile-v1.0
 [root@ubuntu2004 go-hello]#vim Dockerfile
 [root@ubuntu2004 go-hello]#cat Dockerfile
 FROM golang:1.18-alpine as builder
 COPY hello.go /opt
 WORKDIR /opt
 RUN go build hello.go
 
 FROM alpine:3.15.0
 #FROM scratch
 COPY --from=builder /opt/hello /opt/hello
 #COPY --from=0 /opt/hello /opt/hello
 CMD ["/opt/hello"]
 
 [root@ubuntu2004 go-hello]#bash build.sh v2.0
 [root@ubuntu2004 go-hello]#docker run --name hello2 go-hello:v2.0
```

##### 生产案例: 制作自定义tomcat业务镜像

1 自定义 CentOS 系统基础镜像

2 构建JDK 镜像

3 执行构建脚本制作镜像

4.从镜像启动容器测试

5.从JDK镜像构建tomcat 8 Base镜像

6.构建业务镜像

##### 生产案例: 构建haproxy镜像

##### 生产案例: 基于 Alpine 基础镜像制作 Nginx 镜像

## 1.4docker数据管理

### 1.4.1容器的数据管理介绍

#### 1.4.1.1Docker容器的分层

容器的数据分层目录 

LowerDir:  image 镜像层,即镜像本身，只读 

UpperDir:  容器的上层,可读写 ,容器变化的数据存放在此处 

MergedDir:  容器的文件系统，使用Union FS（联合文件系统）将lowerdir 和 upperdir 合并完成 后给容器使用,最终呈现给用户的统一视图 

WorkDir:  容器在宿主机的工作目录,挂载后内容会被清空，且在使用过程中其内容用户不可见

```bash
[root@ubuntu1804 ~]#docker inspect
```

### 1.4.2数据卷

数据卷实际上就是宿主机上的目录或者是文件，可以被直接mount到容器当中使用

数据库日志输出静态web页面 应用配置文件 多容器间目录或文件共享

```bash
-v <宿主机绝对路径的目录或文件>:<容器目录或文件>

#查看数据卷的挂载关系
docker inspect --format="{{.Mounts}}"  <容器ID>

#删除所有数据卷
[root@ubuntu1804 ~]#docker volume rm `docker volume ls -q`

#删除不再使用的数据卷
[root@ubuntu1804 ~]#docker volume prune  -f
[root@ubuntu1804 ~]#docker volume ls
```

关于匿名数据卷和命名数据卷

使用 docker volume create <卷名> 形式创建并命名的卷；而匿名卷就是没名 字的卷，一般是 docker run -v /data 这种不指定卷名的时候所产生

#### 只读方法挂载数据卷

默认数据卷为可读可写，加ro选项，可以实现只读挂载，对于不希望容器修改的数据，比如:  配置文 件，脚本等，可以用此方式挂载

```bash
[root@ubuntu1804 ~]#docker run  -d -v /data/testdir:/data/nginx/html/:ro   -p 
8004:80 nginx-alpine:1.16.1
```

#### 删除容器

删除容器后，宿主机的数据卷还存在，可继续给新的容器使用

```bash
[root@ubuntu1804 ~]#docker rm -f `docker ps -aq`
[root@ubuntu1804 ~]#cat /data/testdir/index.html 
#新建的容器还可以继续使用原有的数据卷
[root@ubuntu1804 ~]#docker run  -d -v /data/testdir:/data/nginx/html/   -p 8003:80 nginx-alpine:1.16.1
```

#### 实战案例：MySQL使用的数据卷

#### 实战案例: 文件数据卷

文件挂载用于很少更改文件内容的场景，比如: nginx 的配置文件、tomcat的配置文件等。

### 1.4.3数据卷容器

![image-20250512185835935](./image-20250512185835935.png)

在Dockerfile中创建的是匿名数据卷,无法直接实现多个容器之间共享数据

**缺点:  因为依赖一个 Server  的容器，所以此 Server 容器出了问题，其它 Client容器都会受影响**

**据卷容器最大的功能是可以让数据在多个docker容器之间共享**

```bash
--volumes-from <数据卷容器>
```

1 创建一个数据卷容器 Server

```bash
#数据卷容器一般无需映射端口
[root@ubuntu1804 ~]#docker run -d --name volume-server -v /data/bin/catalina.sh:/apps/tomcat/bin/catalina.sh:ro -v /data/testapp:/data/tomcat/webapps/testapp   tomcat-web:app1
```

2 启动多个数据卷容器 Client

```bash
[root@ubuntu1804 ~]#docker run -d --name client1 --volumes-from volume-server -p 8081:8080  tomcat-web:app1
[root@ubuntu1804 ~]#docker run -d --name client2 --volumes-from volume-server -p 8082:8080  tomcat-web:app1
```

3 验证访问

```bash
[root@ubuntu1804 ~]#curl 127.0.0.1:8081/testapp/
```

4 进入容器测试读写

进入 Server 容器修改数据

进入 Client 容器修改数据

5 在宿主机直接修改

6 关闭卷容器Server测试能否启动新容器

关闭卷容器Server，仍然可以创建新的client容器及访问旧的client容器

7 删除源卷容器Server，访问client和创建新的client容器

删除数据卷容器后，旧的client 容器仍能访问，但无法再创建基于数据卷容器的新的client容器,但可以 创建基于已创建的Client容器的Client容器

8 重新创建容器卷 Server

重新创建容器卷容器后，还可继续创建新client 容器

#### **利用数据卷容器备份指定容器的数据卷实现**

由于匿名数据卷在宿主机中的存储位置不确定,所以为了方便的备份匿名数据卷,可以利用数据卷容器实现 数据卷的备份

```bash
#创建需要备份的匿名数据卷容器
[root@ubuntu1804 ~]#docker run -it -v /datavolume1  --name volume-server centos bash
 #可以看到数据卷对应的宿主机目录
[root@ubuntu1804 ~]#docker inspect --format="{{.Mounts}}" volume-server
 #基于前面的匿名数据卷容器创建执行备份操作的容器
[root@ubuntu1804 ~]#docker run -it --rm --volumes-from volume-server -v ~/backup:/backup --name backup-server ubuntu
#删除容器的数据
[root@ubuntu1804 ~]#docker start -i volume-server
#进行还原
[root@ubuntu1804 ~]#docker run --rm --volumes-from volume-server -v ~/backup:/backup --name backup-server ubuntu tar xvf /backup/data.tar -C /datavolume1/

 #验证是否还原
[root@ubuntu1804 ~]#docker start -i volume-server 
[root@88bbc22a3072 /]# ls /datavolume1/
```



## 1.5Docker 网络管理

 https://docs.docker.com/network/

### 1.5.1Docker安装后默认的网络设置

Docker服务安装完成之后，默认在每个宿主机会生成一个名称为docker0的网卡其IP地址都是 172.17.0.1/16

```bash
[root@ubuntu1804 ~]#apt -y install bridge-utils
 [root@ubuntu1804 ~]#brctl show
```

### 1.5.2创建容器后的网络配置

每次新建容器后，宿主机多了一个虚拟网卡，和容器的网卡组合成一个网卡，比如:  137: veth8ca6d43@if136，而在 容器内的网卡名为136，可以看出和宿主机的网卡之间的关联

容器会自动获取一个172.17.0.0/16网段的随机地址，默认从172.17.0.2开始分配给第1个容器使 用，第2个容器为172.17.0.3，以此类推

```bash
#将docker0的IP修改为指定IP
#方法1
[root@ubuntu1804 ~]#vim /etc/docker/daemon.json 
[root@ubuntu1804 ~]#cat /etc/docker/daemon.json
{
 "bip": "192.168.100.1/24",
 "registry-mirrors": ["https://si7y70hh.mirror.aliyuncs.com"]
}
[root@ubuntu1804 ~]#systemctl restart docker.service

#方法2
 [root@ubuntu1804 ~]#vim /lib/systemd/system/docker.service
 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --bip=192.168.100.1/24
 
 [root@ubuntu1804 ~]#systemctl daemon-reload 
[root@ubuntu1804 ~]#systemctl restart docker.service

#修改默认网络设置使用自定义网桥
 [root@ubuntu1804 ~]#apt -y install bridge-utils
 [root@ubuntu1804 ~]#brctl addbr br0
 [root@ubuntu1804 ~]#ip a a 192.168.100.1/24 dev br0
 [root@ubuntu1804 ~]#brctl  show
 [root@ubuntu1804 ~]#vim /lib/systemd/system/docker.service 
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -b br0
 [root@ubuntu1804 ~]#systemctl daemon-reload 
[root@ubuntu1804 ~]#systemctl restart docker

[root@ubuntu1804 ~]#docker run  --rm alpine hostname -i
```

容器获取的地址并不固定,每次容器重启,可能会发生地址变化

**同一个宿主机的不同容器可相互通信**

**不同宿主机之间的容器IP地址重复，默认不能相互通信**

```bash
#禁止同一个宿主机的不同容器间通信，--icc=false
[root@ubuntu1804 ~]#vim /lib/systemd/system/docker.service
 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --icc=false
 [root@ubuntu1804 ~]#systemctl daemon-reload
 [root@ubuntu1804 ~]#systemctl restart docker
```

### 1.5.3通过容器名称互联

即在同一个宿主机上的容器之间可以通过自定义的容器名称相互访问，比如:  一个业务前端静态页面是 使用nginx，动态页面使用的是tomcat，另外还需要负载均衡调度器，如:  haproxy 对请求调度至nginx 和tomcat的容器，由于容器在启动的时候其内部IP地址是DHCP 随机分配的，而给容器起个固定的名 称，则是相对比较固定的，因此比较适用于此场景

```bash
docker run --link <目标通信的容器ID或容器名称> #最好是名称
[root@ubuntu1804 ~]#docker run -it  --rm --name server2  --link server1  alpine:3.11 sh
/ # cat /etc/hosts
/ # ping server1
```

### 1.5.4通过自定义容器别名互联

### 1.5.5Docker 网络连接模式

Docker 的网络支持5种网络模式:   none bridge host container network-name

**默认新建的容器使用Bridge模式**，创建容器时，docker run 命令使用以下选项指定网络模式

```bash
[root@ubuntu1804 ~]#docker network ls

docker run --network <mode>
docker run --net=<mode>
```

### 1.5.6通过宿主机的物理网卡利用SNAT访问外部网络

```bash
#在另一台主机上建立httpd服务器
[root@centos7 ~]#systemctl is-active httpd
active
#启动容器，默认是bridge网络模式
[root@ubuntu1804 ~]#docker run -it  --rm  alpine:3.11 sh
 #可能访问其它宿主机
/ # ping 10.0.0.7
/ # ping www.baidu.com
/ # traceroute 10.0.0.7
/ # wget -qO - 10.0.0.7
/ # route -n
```

### 1.5.7Host 模式

**如果指定host模式启动的容器，那么新创建的容器不会创建自己的虚拟网卡，而是直接使用宿主机的网 卡和IP地址，因此在容器里面查看到的IP信息就是宿主机的信息，访问容器的时候直接使用宿主机IP+容 器端口即可，不过容器内除网络以外的其它资源，如:  文件系统、系统进程等仍然和宿主机保持隔离**

此模式由于直接使用宿主机的网络无需转换，网络性能最高，但是各容器内使用的端口不能相同，适用 于运行容器端口比较固定的业务

### 1.5.8none 模式

在使用none 模式后，Docker 容器不会进行任何网络配置，没有网卡、没有IP也没有路由，因此默认无 法与外界通信，需要手动添加网卡配置IP等，所以极少使用

### 1.5.9Container 模式

**使用此模式创建的容器需指定和一个已经存在的容器共享一个网络，而不是和宿主机共享网络，新创建 的容器不会创建自己的网卡也不会配置自己的IP，而是和一个被指定的已经存在的容器共享IP和端口范 围，因此这个容器的端口不能和被指定容器的端口冲突，除了网络之外的文件系统、进程信息等仍然保 持相互隔离，两个容器的进程可以通过lo网卡进行通信**

### 1.5.10自定义网络模式

#### 实战案例: 自定义网络

#### **实战案例: 利用自定义网络实现 Redis Cluster**

### 1.5.11同一个宿主机之间不同网络的容器通信

#### 方式1: 利用桥接实现跨宿主机的容器间互联

#### 方式2: 利用NAT实现跨主机的容器间互联

## 1.6容器单机编排工具 Docker Compose

当在宿主机启动较多的容器时候，如果都是手动操作会觉得比较麻烦而且容易出错，此时推荐使用  docker 单机编排工具 docker-compose

### 1.6.1安装和准备

**安装Docker Compose**

方法1: 在线安装，通过pip安装

```bash
Ubuntu:   
# apt  update 
# apt  install -y  python-pip 
CentOS:   
# yum install epel-release 
# yum install -y python-pip 
# pip install --upgrade pip 

#配置加速
[root@ubuntu2004 ~]#mkdir ~/.pip
 [root@ubuntu2004 ~]#cat > ~/.pip/pip.conf <<-EOF
 [global]
 index-url = https://pypi.tuna.tsinghua.edu.cn/simple
 EOF
 
  [root@ubuntu2004 ~]#apt -y install python3-pip
 [root@ubuntu2004 ~]#pip3 install --upgrade pip
 [root@ubuntu2004 ~]#pip3 install docker-compose
 [root@ubuntu2004 ~]#docker-compose --version
 
 #基于python2安装docker-compose
 [root@ubuntu1804 ~]#apt -y install python-pip
 [root@ubuntu1804 ~]#pip install docker-compose
 [root@ubuntu1804 ~]#docker-compose --version
```

方法2: 在线直接从包仓库安装

```bash
#ubuntu安装,此为默认版本
[root@ubuntu1804 ~]#apt -y install docker-compose

#CentOS7安装，依赖EPEL源
[root@centos7 ~]#yum -y install docker-compose
```

方法3: 离线安装，直接从github或国内镜像站下载安装对应版本

参看说明:   https://github.com/docker/compose/releases

查看命令格式

官方文档:   https://docs.docker.com/compose/reference/

docker compose 文件格式

官方文档:   https://docs.docker.com/compose/compose-file/

### 1.6.2命令与使用

```bash
#前台启动
[root@ubuntu1804 docker-compose]#docker-compose up
#后台执行
[root@ubuntu1804 docker-compose]#docker-compose  up -d


#上面命令是前台执行，所以要查看结果，可以再开一个终端窗口进行观察
[root@ubuntu1804 ~]#docker ps
[root@ubuntu1804 ~]#docker-compose ps

[root@ubuntu1804 docker-compose]#docker-compose images

[root@ubuntu1804 docker-compose]#docker-compose exec service-nginx-web bash
[root@17c17ad30193 /]# tail -f /apps/nginx/logs/access.log

[root@ubuntu1804 docker-compose]#docker-compose start
 #关闭容器
[root@ubuntu1804 docker-compose]#docker-compose kill
#只删除停止的容器
[root@ubuntu1804 docker-compose]#docker-compose rm
 #停止并删除容器及镜像
[root@ubuntu1804 docker-compose]#docker-compose down
```

停止和启动与日志查看

```bash
[root@ubuntu1804 docker-compose]#docker-compose stop
[root@ubuntu1804 docker-compose]#docker-compose start

[root@ubuntu1804 docker-compose]#docker-compose  ps 
```

从 docker compose 启动多个容器

```bash
[root@ubuntu1804 docker-compose]#cat  docker-compose.yml 
service-nginx-web:
  image: 10.0.0.102/example/nginx-centos7-base:1.6.1
  container_name: nginx-web 
  volumes:- /data/nginx:/apps/nginx/html/#指定数据卷，将宿主机/data/nginx挂载到容器/apps/nginx/html
  expose:
    - 80 
    - 443
  ports 
    - "80:80"
    - "443:443"
service-tomcat-app1:
  image: 10.0.0.102/example/tomcat-web:app1
  container_name: tomcat-app1
  expose:
    - 8080
  ports:
    - "8081:8080"
service-tomcat-app2:
  image: 10.0.0.102/example/tomcat-web:app2
  container_name: tomcat-app2
  expose:
    - 8080
  ports:
    - "8082:8080"
```

### 1.6.3 一键生成 Docker Compose

https://www.composerize.com/

## 1.7Docker 仓库管理

公有云仓库:  由互联网公司对外公开的仓库 

官方 

**阿里云**等第三方仓库

私有云仓库:  组织内部搭建的仓库，一般只为组织内部使用，常使用下面软件搭建仓库

**docker registory** 

**docker harbor**

### 1.7.1私有云单机仓库Docker Registry

### 1.7.2Docker 之分布式仓库 Harbor

harbor 官方github 地址:   https://github.com/vmware/harbor

**编辑 harbor 配置文件**

https://github.com/goharbor/harbor/blob/master/docs/install-config/configure-yml-file.md

#### 一键安装Harbor脚本

#### 使用

1 建立项目

2 命令行登录 harbor

3 给本地镜像打标签并上传到 Harbor

```bash
[root@ubuntu1804 ~]#docker tag alpine-base:3.11 10.0.0.101/example/alpine-base:3.11
 [root@ubuntu1804 ~]#docker push 10.0.0.101/example/alpine-base:3.11

```

#### 实现 Harbor 高可用

![image-20250511183439659](./image-20250511183439659.png)

#### Harbor 安全 Https 配置

## 1.8Docker 的资源限制

官方文档:   https://docs.docker.com/config/containers/resource_constraints/

WARNING: No swap limit support  #没有启用 swap 限制功能会出现此提示警报 可通过修改内核参数消除以上警告 官方文档:   https://docs.docker.com/install/linux/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities

### 1.8.1OOM （Out of Memory Exception）

Out of Memory  Exception,内存溢出、内存泄漏、内存异常

![image-20250511183710229](./image-20250511183710229.png)

产生 OOM 异常时， Dockerd尝试通过调整 Docker 守护程序上的 OOM 优先级来减轻这些风险，以便 它比系统上的其他进程更不可能被杀死但是每个容器 的 OOM 优先级并未调整， 这使得单个容器被杀死 的可能性比Docker守护程序或其他系统进程被杀死的可能性更大，不推荐通过在守护程序或容器上手动 设置-- oom -score-adj为极端负数，或通过在容器上设置 -- oom-kill-disable来绕过这些安全措施

**OOM 优先级机制**:   linux会为每个进程计算一个分数，最终将分数最高的kill 

```bash
/proc/PID/oom_score_adj 
#范围为 -1000 到 1000，值越高容易被宿主机 kill掉，如果将该值设置为 -1000 ，则进程永远不会被宿主机 kernel kill 
/proc/PID/oom_adj 
#范围为 -17 到+15 ，取值越高越容易被干掉，如果是 -17 ， 则表示不能被 kill ，该设置参数的存在是为了和旧版本的 Linux 内核兼容。 
/proc/PID/oom_score 
#这个值是系统综合进程的内存消耗量、 CPU 时间 (utime + 存活时间 (uptime - start time) 和 oom_adj 计算出的进程得分 ，消耗内存越多得分越高，容易被宿主机 kernel 强制杀死 
```

查看OOM相关值

```bash
#按内存排序
[root@ubuntu1804 ~]#top
[root@ubuntu1804 ~]#cat /proc/19674/oom_adj 
0
[root@ubuntu1804 ~]#cat /proc/19674/oom_score
32
[root@ubuntu1804 ~]#cat /proc/19674/oom_score_adj 
0
[root@ubuntu1804 ~]#cat /proc/7108/oom_adj 
0
[root@ubuntu1804 ~]#cat /proc/7108/oom_score
1
[root@ubuntu1804 ~]#cat /proc/7108/oom_score_adj 
0

#docker服务进程的OOM默认值
[root@ubuntu1804 ~]#cat /proc/`pidof dockerd`/oom_adj-8
[root@ubuntu1804 ~]#cat /proc/`pidof dockerd`/oom_score
0
[root@ubuntu1804 ~]#cat /proc/`pidof dockerd`/oom_score_adj-500
```

### 1.8.2Stress-ng 压力测试工具

stress-ng是一个压力测试工具，可以通过软件仓库进行安装，也提供了docker版本的容器 

官方链接：https://kernel.ubuntu.com/~cking/stress-ng/ 

官方文档：https://wiki.ubuntu.com/Kernel/Reference/stress-ng

```bash
[root@ubuntu1804 ~]#docker pull lorel/docker-stress-ng
```

### 1.8.3容器的内存限制

官文文档:  https://docs.docker.com/config/containers/resource_constraints/

```bash
[root@ubuntu1804 ~]#docker run -e MYSQL_ROOT_PASSWORD=123456 -it --rm -m 1g --oom-kill-disable mysql:5.7.30
[root@ubuntu1804 ~]#sysctl  -a |grep swappiness
```

--memory-swap #只有在设置了 --memory 后才会有意义。使用 Swap,可以让容器将超出限制部分的内存 置换到磁盘上，WARNING:  经常将内存交换到磁盘的应用程序会降低性能

```bash
[root@ubuntu1804 ~]#docker run -it --rm -m 2G centos:centos7.7.1908 bash
```

**使用stress-ng测试内存限制**

```bash
[root@ubuntu1804 ~]#docker run --name c1 -it --rm lorel/docker-stress-ng --vm 2

#因上一个命令是前台执行，下面在另一个终端窗口中执行，可以看到占用512M左右内存
[root@ubuntu1804 ~]#docker stats

[root@ubuntu1804 ~]#vim /etc/default/grub
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1  net.ifnames=0"
```

内存限制200m

```bash
 #宿主机限制容器最大内存使用:   
[root@ubuntu1804 ~]#docker run  -it --rm  --name c1 -m 200M lorel/docker-stress-ng --vm 2 --vm-bytes 256M 
[root@ubuntu1804 ~]#docker stats --no-stream

#查看宿主机基于 cgroup 对容器进行内存资源的大小限制 
[root@ubuntu1804 ~]#cat /sys/fs/cgroup/memory/docker/f69729b2acc16e032658a4efdab64d21ff97dcb6746d1cef451ed82d5c98a81f/memory.limit_in_bytes

[root@ubuntu1804 ~]#echo 314572800 > /sys/fs/cgroup/memory/docker/f69729b2acc16e032658a4efdab64d21ff97dcb6746d1cef451ed82d5c98a81f/memory.limit_in_bytes
```

内存大小软限制

```bash
[root@ubuntu1804 ~]#docker run -it --rm  -m 256m --memory-reservation 128m -name c1 lorel/docker-stress-ng --vm 2 --vm-bytes 256M 
```

### 1.8.4容器的 CPU 限制

官方文档说明:   https://docs.docker.com/config/containers/resource_constraints/

![image-20250512015259067](./image-20250512015259067.png)

```bash
 #占用4个CPU资源.但只是平均的使用CPU资源
[root@ubuntu1804 ~]#docker run -it --rm  --name c1 lorel/docker-stress-ng  --cpu 4

#最多使用合计1.5个cpu资源
[root@ubuntu1804 ~]#docker run -it --rm  --name c1 --cpus 1.5  lorel/docker-stress-ng  --cpu 4

#同时开两个容器，满载情况下c1的配额是c2配额的两倍
[root@ubuntu1804 ~]#docker run -it --rm  --name c1 --cpu-shares 1000  lorel/docker-stress-ng  --cpu 4

[root@ubuntu1804 ~]#docker run -it --rm  --name c2 --cpu-shares 500  lorel/docker-stress-ng  --cpu 4
```



# 2.Kubernetes

![image-20250513164955614](./image-20250513164955614.png)

[二进制部署Kubernetes 1.23.15版本高可用集群实战 - 尹正杰 - 博客园](https://www.cnblogs.com/yinzhengjie/p/17069566.html#一k8s二进制部署准备环境)

![1747130614716](./1747130614716.png)

## 2.1Kubernetes集群架构介绍

### 2.1.1Kubernetes Master Components

**API Server**:

◼ 整个集群的API网关，相关应用程序为kube-apiserver

◼ 基于http/https协议以REST风格提供，几乎所有功能全部抽象为“资源”及相关的“对象”

◼ 声明式API，用于只需要声明对象的“终态”，具体的业务逻辑由各资源相关的Controller负责完成

◼ 无状态，数据存储于etcd中

**Cluster Store**（etcd）:

◼ 集群状态数据存储系统，通常指的就是etcd

◼ 仅会同API Server交互

**Controller Manager**

◼ 负责实现客户端通过API提交的终态声明，相应应用程序为kube-controller-manager

◼ 由相关代码通过一系列步骤驱动API对象的“实际状态”接近或等同“期望状态”

◆ 工作于loop模式

**Scheduler**

◼ 调度器，负责为Pod挑选出（评估这一刻）最合适的运行节点

◼ 相关程序为kube-scheduler

### 2.1.2Kubernetes Worker Components

**Kubelet**

◼ Kubernetes集群于每个Worker节点上的代理，相应程序为kubelet

◼ 接收并执行Master发来的指令，管理由Scheduler绑定至当前节点上的Pod对象的容器

◆ 通过API Server接收Pod资源定义，或从节点本地目录中加载静态Pod配置

◆ 借助于兼容CRI的容器运行时管理和监控Pod相关的容器

**Kube Proxy**

◼ 运行于每个Worker节点上，专用于负责将Service资源的定义转为节点本地的实现

◆ iptables模式：将Service资源的定义转为适配当前节点视角的iptables规则

◆ ipvs模式：将Service资源的定义转为适配当前节点视角的ipvs和少量iptables规则

◼ 是打通Pod网络在Service网络的关键所在

### 2.1.3Kubernetes Add-ons

负责扩展Kubernetes集群的功能的应用程序，通常以Pod形式托管运行于Kubernetes集群之上

1.**必选插件**

◼ **Network Plugin**：网络插件，经由CNI接口，负责为Pod提供专用的通信网络，有多种实现

◆CoreOS Flannel

◆ProjectCalico

◆Cilium

◼ **Cluster DNS**：集群DNS服务器，负责服务注册、发现和名称解析，当下的实现是CoreDNS

2.**重要插件**

◼ Ingress Controller：Ingress控制器，负责为Ingress资源提供具体的实现，实现http/https协议的七层路由和流量调度，有多种实现，例如Ingress-Nginx、Contour等

◼ Metrics Server：Node和Pod等相关组件的核心指标数据收集器，它接受实时查询，但不存储指标数据

◼ Kubernetes Dashboard/Kuboard/Rainbond：基于Web的UI

◼ Prometheus：指标监控系统

◼ ELK/PLG：日集中式日志系统

◼ **OpenELB**：适用于非云端部署的Kubernetes环境的负载均衡器，可利用BGP和ECMP协议达到性能最优和高可用性

#### 2.1.4pod

Kubernetes本质上是“以应用为中心”的现代应用基础设施，**Pod**是其运行应用及应用调度的最小逻辑单元

在设计上，仅应该将具有“超亲密”关系的应用分别以不同容器的形式运行于同一Pod内部

##### 2.2.1Service

Pod具有动态性，其IP地址也会在基于配置清单重构后重新进行分配，因而需要服务发现机制的支撑

Kubernetes使用Service资源和DNS服务（CoreDNS）进行服务发现

◼ Service能够为一组提供了相同服务的Pod提供负载均衡机制，其IP地址（Service IP，也称为Cluster IP）即为客户端流量入口

◼ 一个Service对象存在于集群中的各节点之上，不会因个别节点故障而丢失，可为Pod提供固定的前端入口

◼ Service使用**标签选择器**（Label Selector）筛选并匹配Pod对象上的标签（Label），从而发现Pod

![image-20250513182604059](./image-20250513182604059.png)

##### 2.2.2工作负载型控制器

Pod是运行应用的原子单元，其生命周期管理和健康状态监测由kubelet负责完成，而**诸如更新、扩缩容和重建**等应用编排功能需要由专用的**控制器**实现，这类控制器即工作负载型控制器

## 2.2集群部署与应用编排

### 2.2.1集群部署

安装工具

kubeadm不仅支持集群部署，还支持集群升级、卸载、更新数字证书等功能

**部署前提**

◼ 支持Kubernetes运行的Linux主机，例如Debian、RedHat及其变体等

◼ 每主机2GB以上的内存，以及2颗以上的CPU

◼ 各主机间能够通过网络正常通信，支持各节点位于不同的网络中

◼ 独占的hostname、MAC地址以及product_uuid，主机名能够正常解析

◼ 放行由Kubernetes使用到的各端口，或直接禁用iptables

◼ 禁用各主机的上的Swap设备

◼ 各主机时间同步

准备代理服务，以便接入registry.k8s.io，或根据部署过程提示的方法获取相应的Image

![image-20250513185829653](./image-20250513185829653.png)

![image-20250513185950793](./image-20250513185950793.png)

**高可用集群部署参考部署笔记**

#### 集群管理相关的其它常用操作

```bash
#检查证书是否过期
kubeadm certs check-expiration
#手动更新证书
kubeadm certs renew
kubeadm会在控制平面升级时自动更新所有的证书

#重置集群,危险操作，请务必再三确认是否必须要执行该操作
kubeadm reset
负责尽最大努力还原通过 'kubeadm init' 或者 'kubeadm join' 命令对主机所作的更改


#集群升级
升级前，务必要备份所有的重要组件，例如存储在数据库中应用层面的状态等；但kubeadm upgrade并不会影响工作负
载，它只会涉及Kubernetes集群的内部组件；
必须禁用Swap
先升级控制平面节点
而后再升级工作节点
具体的升级步骤
◆官方文档 https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/


#令牌过期后，向集群中添加新节点
#生成新token
kubeadm token create
#获取CA证书的hash编码
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
#将节点加入集群
kubeadm join kubeapi.magedu.com:6443 --token TOKEN --discovery-token-ca-cert-hash sha256:HASH
更为简单的实现方式
◼ 方式一：直接生成将节点加入集群的命令
◆kubeadm token create --print-join-command
◼ 方式二：分两步，先生成token，再生成命令
1. TOKEN=$(kubeadm token generate)
2. kubeadm token create ${TOKEN} --print-join-command
添加控制平面节点
◼ 先上传CA证书，并生成hash
◆kubeadm init phase upload-certs --upload-certs
◼ 而后，生成添加控制平面节点的命令
◆kubeadm token create --print-join-command --certificate-key $CERT_HASH
```

#### API资源规范

**资源规范**:

◼ 绝大多数的Kubernetes对象都包含spec和status两个嵌套字段

​    ◆spec字段存储对象的期望状态（或称为应有状态）

​        ⚫ 由用户在创建时提供，随后也可按需进行更新（但有些属性并不支持就地更新机制）

​        ⚫ 不同资源类型的spec格式不尽相同

​    ◆status字段存储对象的实际状态（或称为当前状态）

​        ⚫ 由Kubernetes系统控制平面相关的组件负责实时维护和更新

◼ 对象元数据

​    ◆名称、标签、注解和隶属的名称空间（不包括集群级别的资源）等

◼ kind和apiVersion两个字段负责指明对象的类型（资源类型）元数据

​    ◆前者用于指定类型标识

​    ◆后者负责标明该类型所隶属的API群组（API Group）



**API Server**

基于HTTP(S)协议暴露了一个RESTful风格的API

kubectl命令或其它UI通过该API查询或请求变更API对象的状态，施加于对象之上的基本操作包括增、删、改、查等，通过HTTP协议的GET、POST、DELETE和PUT等方法完成，而对应于kubectl命令，它们则是create、get、describe、delete、patch和edit等子命令

**API对象管理**

创建对象时，必须向API Server提供描述其所需状态的对象规范、对象元数据及类型元数据

需要在请求报文的body中以JSON格式提供

**资源规范的具体格式**

https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/

内建文档：kubectl explain 命令获取

参考现有资源对象：

```bash
kubectl get TYPE/NAME -o {yaml|json}
```

### 2.2.2应用编排

**指令式命令**

```bash
#编排应用
◼ 仅打印资源清单
◆kubectl create deployment demoapp --image=ikubernetes/demoapp:v1.0 --port=80 --dry-run=client --replicas=3 -o yaml
◼ 创建deployment对象
◆kubectl create deployment demoapp --image=ikubernetes/demoapp:v1.0 --port=80 --replicas=3
◆Deployment控制器确保deployment/demoapp中定义，
◼ 了解完整的资源规范及状态
◆kubectl get deployments [-o yaml|json]
◼ 了解Pod对象的相关信息
◆kubectl get pods -l app=demoapp -o wide

#创建Service对象
◼ 仅打印资源清单
◆kubectl create service clusterip demoapp --tcp=80:80 --dry-run=client -o yaml
◼ 创建Service对象
◆kubectl create service clusterip demoapp --tcp=80:80
◼ 了解Service的相关信息
◆kubectl get services demoapp -o wide
◼ 访问Service
◆demoappIP=$(kubectl get services demoapp -o jsonpath={.spec.clusterIP})
◆curl $demoappIP
```

### 2.2.3名称空间

**系统级名称空间**

default：默认的名称空间，为任何名称空间级别的资源提供的默认设定

kube-system：Kubernetes集群自身组件及其它系统级组件使用的名称空间，Kubernetes自身的关键组件均部署在该名称空间中

kube-public：公众开放的名称空间，所有用户（包括Anonymous）都可以读取内部的资源kube-node-lease：节点租约资源所用的名称空间

所有的系统级名称空间均不能进行删除操作，而且除default外，其它三个也不应该用作业务应用的部署目标

**自定义名称空间**：由用户按需创建

**作用：资源隔离，权限控制**，**提高集群性能**

进行资源搜索时，名称空间有利于Kubernetes API缩小查找范围，从而对减少搜索延迟和提升性能有一定的帮助2.

## 2.3Pod和容器设计模式

一个或多个容器的集合，因而也可称为容器集，但却是Kubernetes调度、部署和运行应用的原子单元

### 2.3.1Pod资源规范的基础框架

#### 2.3.1.1了解Pod的运行状况

```bash
#打印Pod完整的资源规范，通过status字段了解
kubectl get TYPE NAME -o yaml|json
kubectl get pods demoapp -o yaml

#打印Pod资源的详细状态
kubectl describe TYPE NAME

#获取Pod中容器应用的日志
kubectl logs [-f] [-p] (POD | TYPE/NAME) [-c CONTAINER]
kubectl logs demoapp -c demoapp
```

#### 2.3.1.2配置pod

```yaml
apiVersion: v1
kind: Pod
metadata:
name: mydb
namespace: default
spec:
containers:
- name: mysql
image: mysql:8.0
env:
- name: MYSQL_RANDOM_ROOT_PASSWORD
value: 1
- name: MYSQL_DATABASE
value: wpdb
- name: MYSQL_USER
value: wpuser
- name: MYSQL_PASSWORD
value: magedu.com
```

##### 探针

常用的探针(Probe):
	livenessProbe:
		健康状态检查，**周期性检查服务是否存活**，检查结果失败，将"重启"容器(**删除源容器并重新创建新器**)。
		如果容器没有提供健康状态检查，则默认状态为Success。
	readinessProbe:
		可用性检查，周期性检查服务是否可用，从而判断容器是否就绪。
		**若检测Pod服务不可用，则会将Pod从svc的ep列表中移除。**
		**若检测Pod服务可用，则会将Pod重新添加到svc的ep列表中。**
		如果容器没有提供可用性检查，则默认状态为Success。
	startupProbe: (1.16+之后的版本才支持)
		**如果提供了启动探针，则所有其他探针都会被禁用，直到此探针成功为止。**
		**如果启动探测失败，kubelet将杀死容器，而容器依其重启策略进行重启。** 
		如果容器没有提供启动探测，则默认状态为 Success。

	exec:
		执行一段命令，根据返回值判断执行结果。返回值为0或非0，有点类似于"echo $?"。
		
	httpGet:
		发起HTTP请求，根据返回的状态码来判断服务是否正常。
			200: 返回状态码成功
			301: 永久跳转
			302: 临时跳转
			401: 验证失败
			403: 权限被拒绝
			404: 文件找不到
			413: 文件上传过大
			500: 服务器内部错误
			502: 无效的请求
			504: 后端应用网关响应超时
			...
			
	tcpSocket:
		测试某个TCP端口是否能够链接，类似于telnet，nc等测试工具。

```yaml
健康检查(livenessProbe)-exec检测方法
cat > 14-livenessProbe-exec.yaml <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: oldboyedu-linux85-exec-001
  labels:
     apps: myweb
spec:
  containers:
  - name: linux85-exec
    image: harbor.oldboyedu.com/web/nginx:1.20.1-alpine
    command: 
    - /bin/bash
    - -c
    - touch /tmp/oldboyedu-linux85-healthy; sleep 5; rm -f /tmp/oldboyedu-linux85-healthy; sleep 600
    # 健康状态检查，周期性检查服务是否存活，检查结果失败，将重启容器。
    livenessProbe:
      # 使用exec的方式去做健康检查
      exec:
        # 自定义检查的命令
        command:
        - cat
        - /tmp/oldboyedu-linux85
      # 检测服务失败次数的累加值，默认值是3次，最小值是1。当检测服务成功后，该值会被重置!
      failureThreshold: 3
      # 指定多久之后进行健康状态检查，即此时间段内检测服务失败并不会对failureThreshold进行计数。
      initialDelaySeconds: 15
      # 指定探针检测的频率，默认是10s，最小值为1.
      periodSeconds: 1
      # 检测服务成功次数的累加值，默认值为1次，最小值1.
      successThreshold: 1
      # 一次检测周期超时的秒数，默认值是1秒，最小值为1.
      timeoutSeconds: 1
EOF
```

```bash
livenessProbe:
      # 使用httpGet的方式去做健康检查
      httpGet:
        # 指定访问的端口号
        port: 80
        # 检测指定的访问路径
        path: /index.html
      # 检测服务失败次数的累加值，默认值是3次，最小值是1。当检测服务成功后，该值会被重置!
      failureThreshold: 3
      # 指定多久之后进行健康状态检查，即此时间段内检测服务失败并不会对failureThreshold进行计数。
      initialDelaySeconds: 65
      # 指定探针检测的频率，默认是10s，最小值为1.
      periodSeconds: 1
      # 检测服务成功次数的累加值，默认值为1次，最小值1.
      successThreshold: 1
      # 一次检测周期超时的秒数，默认值是1秒，最小值为1.
      timeoutSeconds: 1
```

```bash
livenessProbe:
      # 使用tcpSocket的方式去做健康检查
      tcpSocket:
        port: 80
      # 检测服务失败次数的累加值，默认值是3次，最小值是1。当检测服务成功后，该值会被重置!
      failureThreshold: 3
      # 指定多久之后进行健康状态检查，即此时间段内检测服务失败并不会对failureThreshold进行计数。
      initialDelaySeconds: 15
      # 指定探针检测的频率，默认是10s，最小值为1.
      periodSeconds: 1
      # 检测服务成功次数的累加值，默认值为1次，最小值1.
      successThreshold: 1
      # 一次检测周期超时的秒数，默认值是1秒，最小值为1.
      timeoutSeconds: 1
```

##### 安全上下文

##### 资源需求和限制

            Pod的QoS类别：
                BestEffort: 最低
                    未定义requests和limits
                Burstable
    
                Garanteed：最高
                    cpu.requests == cpu.limits
                    memory.ruquests == memroy.limits 
    
                CPU资源单位：
                    1 == 1000m
                        100m <= 总体上单个核心的10% 
    containers:
      - name: linux85-exec
        image: harbor.oldboyedu.com/web/nginx:1.20.1-alpine
        resources:
        requests:
            memory: "128Mi"
            cpu: "200m"
        limits:
            memory: "512Mi"
            cpu: "400m"

### 2.3.2pod设计模式

**基于容器的分布式系统中常用的3类设计模式**

◼ 单容器模式：单一容器形式运行的应用

◼ 单节点模式：由强耦合的多个容器协同共生

◼ 多节点模式：基于特定部署单元（Pod）实现分布式算法

**单节点多容器模式**

◼ 一种跨容器的设计模式

◼ 目的是在单个节点之上同时运行多个共生关系的容器，因而容器管理系统需要由将它们作为一个原子单位进行统一调度

◼ **Pod概念就是这个设计模式的实现之一**

### 2.3.3pod创建和终止

自主式Pod的创建流程

![image-20250514173350354](./image-20250514173350354.png)

终止

![image-20250514173403901](./image-20250514173403901.png)



### 2.3.4Pod 异常问题排查

![image-20250514175902839](./image-20250514175902839.png)

![image-20250514175952211](./image-20250514175952211.png)

## 2.4存储

**emptydir:Pod对象上的一个临时目录**

当Pod被删除时，数据会被随时删除，其有以下两个作用:

- **对容器的数据进行持久化，当删除容器时数据不会丢失;**

- 可以实现同一个Pod内不同容器之间数据共享;

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: linux85-volume-emptydir-001
spec:
  # 定义存储卷
  volumes:
    # 指定存储卷的名称
  - name: data01
    # 指定存储卷类型为emptyDir类型
    # 当Pod被删除时，数据会被随时删除，其有以下两个作用:
    #    - 对容器的数据进行持久化，当删除容器时数据不会丢失;
    #    - 可以实现同一个Pod内不同容器之间数据共享;
    emptyDir: {} 
  containers:
  - name: web
    image: harbor.oldboyedu.com/web/nginx:1.20.1-alpine
    # 指定挂载点
    volumeMounts:
      # 指定存储卷的名称
    - name: data01
      # 指定容器的挂载目录
      mountPath: /usr/share/nginx/html
  - name: linux
    image: harbor.oldboyedu.com/linux/alpine:latest
    stdin: true
    volumeMounts:
    - name: data01
      mountPath: /oldboyedu-data
```

**hostPath存储卷**:将Pod所在节点上的文件系统的某目录用作存储卷,数据的生命周期与节点相同

```bash
  volumes:
  - name: data01
    emptyDir: {} 
  - name: data02
    # 指定类型为宿主机存储卷，该存储卷只要用于容器访问宿主机路径的需求。 
    hostPath:
      # 指定存储卷的路径
      path: /oldboyedu-data
  containers:
  - name: web
    image: harbor.oldboyedu.com/web/nginx:1.20.1-alpine
    volumeMounts:
    - name: data02
      mountPath: /usr/share/nginx/html
```

**NFS存储卷**

◼ 将nfs服务器上导出（export）的文件系统用作存储卷

◼ nfs是文件系统级共享服务，它支持多路挂载请求，可由多个Pod对象同时用作存储卷后端

```bash
apiVersion: v1
kind: Pod
metadata:
  name: volumes-nfs-demo
  labels:
    app: redis
spec:
  containers:
    - name: redis
      image: redis:alpine
      ports:
      - containerPort: 6379
        name: redisport
      securityContext:
        runAsUser: 999
      volumeMounts:
      - mountPath: /data
        name: redisdata
volumes:
  - name: redisdata
    nfs:
      server: nfs.magedu.com
      path: /data/redis
      readOnly: false
```

#### PV&PVC

以上三种都是在Pod级别定义存储卷，有两个弊端

卷对象的生命周期无法独立于Pod而存在

用户必须要足够熟悉可用的存储及其详情才能在Pod上配置和使用卷

**PV和PVC可用于降低这种耦合关系**

PV（Persistent Volume）是集群级别的资源，负责将存储空间引入到集群中，通常由管理员定义

PVC（Persistent Volume Claim）是名称空间级别的资源，由用户定义，用于在空闲的PV中申请使用符合过滤条件的PV之一，与选定的PV是“一对一”的关系

**基于NFS的静态PV和PVC示例**

```bash
#NFS PV 资源定义示例
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-demo
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: "/data/redis"
    server: nfs.magedu.com
    
    
#PVC 资源定义示例
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-demo
  namespace: default
spec:
  accessModes: ["ReadWriteMany"]
  volumeMode: Filesystem
  resources:
    requests:
      storage: 3Gi
    limits:
      storage: 10Gi
      


#在Pod上使用PVC卷
apiVersion: v1
kind: Pod
metadata:
  name: volumes-pvc-demo
  namespace: default
spec:
  containers:
  - name: redis
    image: redis:alpine
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 6379
      name: redisport
    volumeMounts:
    - mountPath: /data
      name: redis-rbd-vol
volumes:
- name: redis-rbd-vol
  persistentVolumeClaim:
    claimName: pvc-demo
```



#### StorageClass资源

Kubernetes支持的标准资源类型之一

为管理PV资源之便而按需创建的存储资源类别（逻辑组）

```bash
#StorageClass资源示例
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.default.svc.cluster.local
  share: /
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4.1
  
#PVC向StorageClass申请绑定PV
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-dynamic
spec:
  accessModes:
    - ReadWriteMany
resources:
  requests:
    storage: 10Gi
storageClassName: nfs-csi
```

![image-20250515162915213](./image-20250515162915213.png)

#### 节点本地持久卷

基于网络存储的PV通常性能损耗较大

**直接使用节点本地的SSD磁盘可获取较好的IO性能，更适用于存储类的服务，例如MongoDB、Ceph等**

基于local的PV，需要管理员通过nodeAffinity声明其定义在的节点

◆用户可通过PVC关联至local类型的PV

◆然后，在Pod上配置使用该PVC即可

◆调度器将基于nodeAffinity将执行Pod调度

**local卷只能关联静态置备的PV，目前尚不支持动态置备**

```bash
#Local PV资源示例
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-demo
spec:
  capacity:
    storage: 5Gi
volumeMode: Filesystem
accessModes:
- ReadWriteOnce
persistentVolumeReclaimPolicy: Delete
storageClassName: local-storage
local:
  path: /disks/vol1
nodeAffinity:
  required:
    nodeSelectorTerms:
    - matchExpressions:
      - key: kubernetes.io/hostname
        operator: In
        values:
        - k8s-node01.magedu.com
```

![image-20250515163442351](./image-20250515163442351.png)

#### K8S存储架构简介

**CSI插件**

CSI（Container Storage Interface）插件的主要作用是为Kubernetes提供一个标准化的方式来与外部存储系统进行交互。它使得存储供应商能够开发统一的驱动程序，而无需修改Kubernetes的核心代码。通过CSI插件，用户可以：

- 动态地供应和管理持久卷（Persistent Volumes, PVs），包括创建、删除、挂载、卸载等操作。
- 支持多种类型的存储服务，如块存储、文件存储等。
- 实现高级功能，例如快照、克隆、扩容等。

#### CAS

容器附加存储（Container Attached Storage）

**CAS的工作原理**

1. **直接连接存储资源**：CAS通常通过CSI（Container Storage Interface）插件或特定的存储驱动程序来实现，允许容器直接访问底层存储资源，如本地磁盘、网络存储等。
2. **动态供应**：利用Kubernetes的StorageClass和PersistentVolumeClaim机制，CAS可以实现存储资源的动态分配。这意味着当一个应用程序请求存储时，系统会自动为其分配所需的存储空间，而无需管理员手动干预。
3. **高性能**：由于CAS旨在为容器提供快速的I/O访问，它通常会选择使用本地存储或低延迟的网络存储解决方案，以减少数据访问的延迟并提高整体应用性能。
4. **高可用性和扩展性**：一些CAS解决方案支持跨多个节点的数据复制和故障转移，确保即使在硬件故障的情况下也能保持数据的可用性和一致性。



##### OPENEBS

部署文档 https://openebs.io/docs/user-guides/installation

若需要支持**Jiva**、cStor、Local PV ZFS和**Local PV LVM**等数据引擎，还需要额外部署相关的组件

使用：

**OpenEBS Local PV hostpath 使用**

**OpenEBS Local PV LVM**

## 2.5应用配置

ConfigMap和Secret是Kubernetes系统上两种特殊类型的存储卷

**ConfigMap用于为容器中的应用提供配置数据以定制程序的行为，而敏感的配置信息，例如密钥、证书等则通常由Secret来配置**

**此二者都属于名称空间级别，只能被同一名称空间中的Pod引用**

### 2.5.1configmap

```bash
#命令式命令
kubectl create configmap nginx-confs --from-file=./nginx-conf.d/myserver.conf --from-file=status.cfg=./nginx-conf.d/myserver-status.cfg
```

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-confs
  namespace: default
data:
  status.cfg: | # “|”是键名及多行键值的分割符，多行键值要进行固定缩进
    location /nginx-status { # 该缩进范围内的文本块即为多行键值
    stub_status on;
    access_log off;
    }
  myserver.conf: |
    server {
      listen 8080;
      server_name www.ik8s.io;
      include /etc/nginx/conf.d/myserver-*.cfg;
      location / {
        root /usr/share/nginx/html;
      }
    }
```

在Pod上配置使用ConfigMap示例

![image-20250515173305510](./image-20250515173305510.png)

### 2.5.2Secret

```bash
kubectl create secret generic mysql-root-authn --from-literal=username=root --from-literal=password=MagEdu.c0m
```

```bash
apiVersion: v1
data:
  password: TWFnRWR1LmMwbQ==
  username: cm9vdA==
kind: Secret
metadata:
  name: mysql-root-authn
  namespace: default
type: Opaque
```

**pod中引用secret跟configmap一样**

![image-20250515173816377](./image-20250515173816377.png)

### 2.5.3Image Pull Secret

![image-20250515173936191](./image-20250515173936191.png)

### 2.5.4DownwardAPI和 Projected

DownwardAPI只是一种将Pod的metadata、spec或status中的字段值注入到其内部Container里的方式

## 2.6Service与服务发现

### 2.6.1Service和Endpoints

Service

![image-20250515175001796](./image-20250515175001796.png)

**服务发现**：通过**标签选择器**筛选同一名称空间下的Pod资源的标签，完成Pod筛选

**负载均衡**：由运行各工作节点的kube-proxy根据配置的模式生成相应的流量调度规则

**Endpoints和EndpointSlice**

![image-20250516022238031](./image-20250516022238031.png)

### 2.6.2service及流量转发

![image-20250516141946343](./image-20250516141946343.png)

```bash
apiVersion: v1
kind: Service
metadata:
  name: …
  namespace: …
spec:
type <string> # Service类型，默认为ClusterIP
selector <map[string]string> # 等值类型的标签选择器，内含“与”逻辑
  ports： # Service的端口对象列表
    - name <string> # 端口名称
      protocol <string> # 协议，目前仅支持TCP、UDP和SCTP，默认为TCP
      port <integer> # Service的端口号
      targetPort <string> # 后端目标进程的端口号或名称，名称需由Pod规范定义
      nodePort <integer> # 节点端口号，仅适用于NodePort和LoadBalancer类型
clusterIP <string> # Service的集群IP，建议由系统自动分配
externalTrafficPolicy <string> # 外部流量策略处理方式，Local表示由当前节点处理，Cluster表示向集群范围调度
loadBalancerIP <string> # 外部负载均衡器使用的IP地址，仅适用于LoadBlancer
externalName <string> # 外部服务名称，该名称将作为Service的DNS CNAME值

#NodePort Service
kind: Service
apiVersion: v1
metadata:
  name: demoapp
spec:
  type: NodePort # 必须明确给出Service类型
  selector:
    app: demoapp
ports:
- name: http
  protocol: TCP
  port: 80
  targetPort: 80
  nodePort: 30080 # 可选，为避免冲突，建议由系统动态分配
```

#### NodePort Service流量策略

流量策略一：Cluster，表示在整个Kubernetes集群范围内调度；该流量策略下，请求报文从某个节点上的NodePort进入，该节点上的Service会将其调度至任何一个可用后端Pod之上，而不关心Pod运行于哪个节点；

流量策略二：Local，表示仅将请求调度至当前节点上运行的可用后端端点；

#### LoadBalancer类型的Service

在接入外部流量方面，NodePort存在着几个方面的问题

◼ 非知名端口、**私网IP地址、节点故障转移、节点间负载均衡、识别能适配到某Service的Local流量策略的节点**等

◼ 外置的Cloud Load Balancer可以解决以上诸问题，Kubernetes通过调用IaaS平台的功能来创建LoadBalancer

◼ 目前，裸机集群的Load Balancer没有任何可用的默认实现

**非云环境中的LoadBalancer**

◼ 部署于裸机或类似裸机环境中的Kubernetes集群，缺少可用的LBaaS服务

◼ MetalLB和OpenELB等项目为此提供了解决方案

![image-20250516144342433](./image-20250516144342433.png)

![image-20250516150404261](./image-20250516150404261.png)

![image-20250516150810227](./image-20250516150810227.png)

#### ExternalIP

在Service上使用ExternalIP

◼ Service可通过使用节点上配置的辅助IP地址接入集群外部客户端流量

◼ 流量入口仅能是配置有该IP地址的节点，其它节点无效，因而此时在节点间无负载均衡的效果

◼ external IP所在的节点故障后，该流量入口失效，除非将该IP地址转移配置到其它节点

◼ 是除了LoadBalancer和NodePort外，接入外部流量的又一种方式

#### Headless Service



### 2.6.3标签和标签选择器

标签：附加在资源对象上的键值型元数据

```bash
kubectl label
```

标签选择器：基于标签筛选对象的过滤条件，支持两种类型

操作符：=或==、!=，in、notin和exists

### 2.6.4service名称解析

CoreDNS是K8S默认DNS服务器

    ClusterIP Service:
        CoreDNS: 
            API Server的客户端，注册监视每个Service的变动
                自动为每个Service生成FQDN格式的名称
                    <service_name>.<namespace>.svc.<zone>
                        <zone>: cluster.local 
    
                    例如：default/demoapp: demoapp.default.svc.cluster.local
    
                    dev/pod --> kube-system/openebs 
                        dev.svc.cluster.local svc.cluster.local cluster.local 
                        
                        openebs.kube-system   
                自动生资源记录



### 2.6.5Pod上的DNS解析策略

![image-20250516160048607](./image-20250516160048607.png)

![image-20250516160250541](./image-20250516160250541.png)

## 2.7应用编排

Kubernetes的声明式API

### 2.7.1kubernetes控制器模式

**Kubernetes Controller的控制回路**

◼ Controller根据spec，控制System生成Status

◼ Controller借助于Sensor持续监视System的Spec和Status，在每一次控制回路中都会对二者进行比较，并确保System的Status不断逼近或完全等同Status

**以编排Pod化运行的应用为核心的控制器，通常被统称为工作负载型控制器**

◼ 无状态应用编排：ReplicaSet、Deployment

◼ 有状态应用编排：StatefulSet、第三方专用的Operator

◼ 系统级应用：DaemonSet

◼ 作业类应用：Job和CronJob

### 2.7.2deployment资源及控制器

![image-20250516170027388](./image-20250516170027388.png)

![image-20250516170057604](./image-20250516170057604.png)

![image-20250516172440767](./image-20250516172440767.png)

**maxSurge：指定升级期间存在的总Pod对象数量最多可超出期望值的个数，其值可以是0或正整数，也可以是相对于期望值的一个百分比**

**maxUnavailable：升级期间正常可用的Pod副本数（包括新旧版本）最多不能低于期望值的个数，其值可以是0或正整数，也可以是相对于期望值的一个百分比，默认值为1**

![image-20250516172515547](./image-20250516172515547.png)

![image-20250516172735381](./image-20250516172735381.png)

### 2.7.3daemonSet

**DaemonSet用于确保所有或选定的工作节点上都运行有一个Pod副本**

◆提示：DaemonSet的根本目标在于让每个节点一个 Pod

◆**有符合条件的新节点进入时，DaemonSet会将Pod自动添加至相应节点；而节点的移出，相应的Pod副本也将被回收；**

常用场景

◼ 特定类型的系统化应用，例如kube-proxy，以及Calico网络插件的节点代理calico-node等

◼ 集群存储守护进程、集群日志收集守护进程以及节点监控守护进程等

**重点理解**：**DaemonSet的资源规范与Deployment相似，DaemonSet对象也使用标签选择器和Pod模板，区别之处在于，DaemonSet不需要定义replicas**

### 2.7.4StatefulSet和Operator

#### StatefulSet

功能：负责编排**有状态（Stateful Application）**应用

有状态应用会在其会话中保存客户端的数据，并且有可能会在客户端下一次的请求中使用这些数据

应用上常见的状态类型：会话状态、连接状态、配置状态、集群状态、持久性状态等

大型应用通常具有众多功能模块，这些模块通常会被设计为有状态模块和无状态模块两部分

◆**业务逻辑模块一般会被设计为无状态，这些模块需要将其状态数据保存在有状态的中间件服务上，如消息队列、数据库或缓存系统等**

![image-20250516174627223](./image-20250516174627223.png)

![image-20250516184357107](./image-20250516184357107.png)

#### Operator

![image-20250516184623456](./image-20250516184623456.png)

![image-20250516184645172](./image-20250516184645172.png)

### 2.7.5Job和cronjob

一次性任务和周期性任务

## 2.8认证体系和service account

### 2.8.1k8s访问控制体系

![image-20250516185147616](./image-20250516185147616.png)

![image-20250516185829139](./image-20250516185829139.png)

### 2.8.2API身份验证

![image-20250516191408723](./image-20250516191408723.png)

### 2.8.3kubeconfig

kubeconfig是YAML格式的文件，用于存储身份认证信息，以便于客户端加载并认证到API Server

### 2.8.4认证测试

![image-20250516194912370](./image-20250516194912370.png)

### 2.8.5service account

## 2.9鉴权体系

![image-20250516200316049](./image-20250516200316049.png)

![image-20250516200554343](./image-20250516200554343.png)

![image-20250516202033872](./image-20250516202033872.png)

### 案例

![image-20250516202120929](./image-20250516202120929.png)

## 2.10ingress与应用发布

### 2.10.1Ingress和Ingress Controller

将服务类应用暴露至集群外部的方法：
NodePort Service 
LoadBalancer Service 

使用专用NodePort来暴露服务
Service with ExternalIP 
使用专用的ExternalIP来暴露服务

![image-20250516202416872](./image-20250516202416872.png)

**Ingress**：Ingress需要借助于Service资源来发现后端端点

◼ Kubernetes上的标准API资源类型之一

◼ 仅定义了抽象路由配置信息，只是元数据，需要由相应的控制器动态加载

**Ingress Controller**：反向代理服务程序，需要监视API Server上Ingress资源的变动，并将其反映至自身的配置文件中

**Ingress Controller会基于Ingress的定义将流量直接发往其相关Service的后端端点，该转发过程并不会再经由Service进行**

```bash
#参考 https://kubernetes.github.io/ingress-nginx/deploy/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
```

### 2.10.2ingress类型

![image-20250516203250988](./image-20250516203250988.png)

![image-20250516203304362](./image-20250516203304362.png)

![image-20250516203407680](./image-20250516203407680.png)

### 2.10.3ingress资源

![image-20250516203631869](./image-20250516203631869.png)

### 2.10.4基于ingress nginx的灰度发布

![image-20250516204521604](./image-20250516204521604.png)

## 2.11helm程序包管理器

### 2.11.1helm基础

Helm是一款简化安装和管理Kubernetes应用程序的工具

Chart代表着可由Helm管理的有着特定格式的程序包，Chart中的资源配置文件通常以**模板**（go template）形式定义，在部署时，用户可通过向模板参数赋值实现定制化安装的目的

类似于kubectl，Helm也是Kubernetes API Server的命令行客户端工具

创建Chart

◆https://helm.sh/zh/docs/topics/charts/

## 2.12网络插件及流量转发机制

### 2.12.1pod网络的解决方案

![image-20250516211657856](./image-20250516211657856.png)

![image-20250516211750264](./image-20250516211750264.png)

![image-20250516211844036](./image-20250516211844036.png)

![image-20250516212832983](./image-20250516212832983.png)

### 2.12.2对比主流网络插件

![image-20250516213048771](./image-20250516213048771.png)

### 2.12.3flannel

### 2.12.4Calico网络插件

### 2.12.5network policy

## 2.13k8s扩展机制

## 2.14k8s调度器

### 2.14.1调度器和调度流程介绍

### 2.14.2资源约束和pod QoS

### 2.14.3Affinity Scheduling

**Node Affinity**

**硬亲和与软亲和**

硬亲和：必须满足的亲和约束，约束评估仅发生在调度期间

软亲和：有倾向性的亲和约束，不同的约束条件存在不同的权重，约束评估同样仅发生在调度期间

**基于Pod和Pod间关系的调度策略，称为Pod亲和调度（Affinity），以及Pod反亲和调度（AntiAffinity）**

### 2.14.4Taints与Tolerations

![image-20250516221146847](./image-20250516221146847.png)

Node Taints和Pod Tolerations调度

![image-20250516221008916](./image-20250516221008916.png)

## 2.15k8s指标系统

![image-20250516222750775](./image-20250516222750775.png)

## 2.16K8S集群运维

![image-20250516223117371](./image-20250516223117371.png)

![image-20250516223158050](./image-20250516223158050.png)

![image-20250516223221909](./image-20250516223221909.png)

### 高可用集群部署模型

![image-20250516223316211](./image-20250516223316211.png)

### 升级策略

版本号遵循典型的版本控制机制

◆vX.Y.Z: X为主版本号，Y是次要版本号，Z是补丁版本号

多数工具和组件，通常只允许**一次升级一个次要版本**

落后多个版本进行升级时，升级过程较为耗时，但一次一个次要版本也是确保升级成功的必要策略

![image-20250516223525599](./image-20250516223525599.png)

![image-20250516223700691](./image-20250516223700691.png)

![image-20250516223730319](./image-20250516223730319.png)

文档

◼ https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

### 基于Velero的备份和恢复

# 3.K8S命令总结

部署文档：
​    https://mp.weixin.qq.com/s/7i68jmvi2eo_6wlqYEOupQ

代码仓库：
    https://github.com/iKubernetes/learning-k8s/

```bash
部署应用：
cd learning-k8s/wordpress/
kubectl create namespace blog 
kubectl apply -f mysql-ephemeral
kubectl get service -n blog 

命令式命令：
kubectl create deployment demoapp --image=ikubernetes/demoapp:v1.0 --replicas=3 -n default
kubectl create service clusterip demoapp --tcp=80:80
kubectl scale deployment demoapp --replicas=6
kubectl set image deployment demoapp demoapp=ikubernetes/demoapp:v1.1 && kubectl rollout status deployment demoapp
```

```bash
#-f选项可重复使用多次，-f /PATH/TO/DIR/：加载目录下的所有以.yaml, .yml, .json结尾的文件；
kubectl get
kubectl create
kubectl delete 
kubectl edit
kubectl explain#显示指定资源类型的内建文档
kubectl api-versions     #打印k8s上的所有的资源群组及其版本号
kubectl describe
kubectl logs 
kubectl exec
kubectl run 
kubectl proxy   #给API Server启用一个代理，默认是http协议
```

```bash
kubectl label 
                增加：
                    kubectl label TYPE NAME KEY_1=VAL_1 ... KEY_N=VAL_N

                修改：
                   kubectl label --overwrite TYPE NAME KEY_1=VAL_1 ... KEY_N=VAL_N 

                删除：
                    kubectl label TYPE NAME KEY_1-
```

```bash
kubectl rollout status (TYPE NAME | TYPE/NAME) [flags] [options]
kubectl rollout history (TYPE NAME | TYPE/NAME) [flags] [options]
kubectl rollout undo (TYPE NAME | TYPE/NAME)
kubectl rollout undo (TYPE NAME | TYPE/NAME) --to-revision=X
```

```bash
kubectl api-versions
kubectl explain pod
kubectl explain pod.metadata
```

```bash
helm install
helm uninstall
helm create
helm list
helm upgrade
helm history
helm rollback
#添加公共仓库
helm repo add
helm repo list
helm search repo mysql
helm pull
```

```bash

Kubernetes集群运维：
    命令： kubectl cordon/uncordon
        将节点标记为不可被调度/恢复为可调度

    命令：kubectl drain 
        排空节点上的Pod 

```

```bash
#key和value赋予node唯一标识和含义
kubectl taint node k8s232.oldboyedu.com school=oldboyedu:NoExecute
kubectl describe nodes | grep Taints -A 2#查看
```

