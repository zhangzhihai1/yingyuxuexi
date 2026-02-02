[TOC]

# 1.linux核心命令

## 1.1基础命令补充

```go
tty
whoami            who am i
w
echo $shell

type ls
arch
uname -r
```

## 1.2文件管理与io重定向

```shell
打开/下两层目录树形结构
tree / -d -L 2

pwd
basename            dirname
cd - #上一个目录

stat /boot
dos2unix   unix2dos

mv cp mkdir rmdir rm

df -Th    df -i     df -h

tr    #字符转换       df | tr -s ' '   压缩空格
tee  #将标准输入复制到每个指定文件，并显示到标准输出
```

文件查找

```shell
locate
which whereis  #程序命令

find  -maxdepth/name/type/empty/perm 
      -size +/-10K
      -atime/mtime/ctime +7  #天 最后访问时间/修改时间/元数据变更时间
      -amin/mmin/cmin   -exec command {} \
```

压缩解压缩

```go
tar -zcvf
tar -xf
```

## 1.3用户管理与权限管理

用户管理

```shell
id nginx

useradd
userdel
usermod #修改用户属性，如所属组
passwd Username
chpasswd

groupadd
groupmod 组属性修改
groupdel 可以删除组
gpasswd GROUP
groupmems 可以管理附加组的成员关系
newgrp mage #切换之后创建的文件属组就是mage


su #切换用户
su UserName #非登录式切换，即不会读取目标用户的配置文件，不改变当前工作目录，即不完全切换
su - UserName #登录式切换，会读取目标用户的配置文件，切换至自已的家目录，即完全切换，exit 退回至旧的用户身份，不要再用 su 切换至旧用户，否则会生成很多的bash子进程，环境可能会混乱。
说明：root su至其他用户无须密码；非root用户切换时需要密码

#不切换用户
[root@ubuntu2204 ~]# su - jose -c "touch jose-2.txt"


#修改用户密码策略
chage #可以修改用户密码策略  ，比如密码有效期
```

文件权限

```shell
chown
chgrp
chmod
#新建文件：666-umask，按位对应相减，如果所得结果某位存在执行（奇数）权限，则该位+1；
#新建目录：777-umask；umask

lsattr
chattr
+i    #对文件：不可被删除不可被修改不可重命名；对目录：可修改查看目录中的文件，不可新建文件，不可删除文件
+a   

setfacl
setfacl -m u:jose:rw f1
getfacl f1
```

## 1.4文本处理工具

```go
cat
tac #逆向显示
rev  #将同一行的内容逆向显示，同一行倒序

nl   #显示行号，相当于cat -n

hexdump  #查看非文本文件内容

more
less -N

head
tail

cut #cut 命令可以提取文本文件或STDIN数据的指定列
-d|--delimiter=DELIM   #指定分割符，默认是tab
-f|--fields=LIST       #要显示的列，-f1, -f1,2,3, -f 1-3,4

wc -l #统计

sort
-n|--numeric-sort         #以数字大小排序
-r|-reverse               #倒序
-t|--field-separator=SEP   #指定列分割符
-k|--key=KEYDEF           #指定排序列
-u|--unique               #去重
[root@ubuntu2204 ~]# cut -d: -f1,3 /etc/passwd|sort -t: -k2 -nr |head -n3
nobody:65534
jerry:1003
tom:1002
#统计日志访问量
[root@ubuntu2204 ~]# cut -d" " -f1 /var/log/nginx/access_log |sort -u|wc -l
201

uniq -c  #行去重并显示每行出现的次数，只能处理连续重复行，所以要先排序
#统计日志访问量最多的前三名的请求
[root@ubuntu2204 ~]# lastb | head -n $(echo `lastb | wc -l`-2 | bc) | tr -s ' ' | cut -d " " -f3 | sort | uniq -c | sort -nr | head -3
      5 183.136.225.32
      2 47.101.154.149
      1 64.62.197.96
      
diff #比较文件

vimdiff f1.txt f2.txt #vim打开比较两个文件
```

通配符

通配符与基本正则的使用场景：shell解析，通配符使用在文件名匹配，正则则是文本匹配

```go
.：匹配任意一个字符
*：匹配任意内容
?：匹配任意一个内容
[]：匹配中括号中的一个字符
```

基本正则

单字符

```go
.   匹配任意单个字符，当然包括汉字的匹配
[]  匹配指定范围内的任意单个字符
[^] 匹配指定范围外的任意单个字符
|  匹配管道符左侧或者右侧的内容
```

匹配次数

```shell
* #匹配前面的字符任意次，包括0次
.* #任意长度的任意字符
\? #匹配其前面的字符出现0次或1次,即:可有可无
\+ #匹配其前面的字符出现最少1次,即:肯定有且 >=1 次
\{n\} #匹配前面的字符n次
\{m,n\} #匹配前面的字符至少m次，至多n次
\{,n\} #匹配前面的字符至多n次,<=n
\{n,\} #匹配前面的字符至少n次
```

位置锚定

```go
^ #行首锚定, 用于模式的最左侧
$ #行尾锚定，用于模式的最右侧
^PATTERN$ #用于模式匹配整行
^$ #空行
^[[:space:]]*$ #空白行
\<PATTERN\>       #匹配整个单词
```

分组

```go
[root@ubuntu2204 ~]# echo abc-def-abcabcabc | grep "^\(abc\)-\(def\)-\1\{3\}"
abc-def-abcabcabc
```

扩展正则

匹配次数

```go
*   #匹配前面字符任意次
? #0或1次
+ #1次或多次
{n} #匹配n次
{m,n} #至少m，至多n次
```

### 三剑客

grep

```go
grep
-m 3 #取前三行
-v  #取反
-i  #不区分大小写
-n   #显示行号
```

sed

```shell
-n|--quiet|--silent #不输出模式空间内容到屏幕，即不自动打印
--------------------------------打印
#等待标准输入,script为空，默认是直接输出
[root@ubuntu2204 ~]# sed ''
123
123
#script为空，默认输出内容
[root@ubuntu2204 ~]# sed '' /etc/issue
Ubuntu 22.04 LTS \n \l
#script 中执行p命令，再加上默认输出，所有每行都显示了两次
[root@ubuntu2204 ~]# sed 'p' /etc/issue                  #p,print
Ubuntu 22.04 LTS \n \l
Ubuntu 22.04 LTS \n \l
#输出第一行
[root@ubuntu2204 ~]# sed -n '1p' /etc/passwd
#输出最后一行
[root@ubuntu2204 ~]# sed -n '$p' /etc/passwd

----------------------------------------------匹配
#正则匹配，输出包含root的行
[root@rocky86 ~]# sed -n '/root/p' /etc/passwd
#正则匹配行首#，显示注释行行号
[root@rocky86 0723]# sed -n '/^#/=' /etc/fstab
#行号开始，正则结束
[root@rocky86 0723]# sed -n '8,/root/p' /etc/passwd
------------------------------------------------插入
#bbb后插入
[root@ubuntu2204 ~]# sed '/bbb/a\---' test.txt
#2-4行前插入
[root@ubuntu2204 ~]# sed '2,4i\---' test.txt
#举一反三行尾插入用替换行尾符
sed '/final/s/$/---/g' data.txt
---------------------------------------------替换
#搜索替换
[root@rocky86 0723]# sed -n 's/root/ROOT/gp' /etc/passwd
------------------------------------------------追加\
# \ 的作用
[root@ubuntu2204 ~]# sed '2a   *******' test.txt 
aaa
bbb
*******
[root@ubuntu2204 ~]# sed '2a\   *******' test.txt 
aaa
bbb
   *******

----------------------------------------------#或
#-e 多个script
[root@ubuntu2204 ~]# #sed -e '2d' -e '4d' seq.log
[root@ubuntu2204 ~]# sed '2d;4d' seq.log

------------------------------------------------修改文件
[root@ubuntu2204 ~]# sed -i '2,7d' 10.txt

混合用法（基本用法扩展）
#打印倒数第二行
sed -n "$(echo $[`cat /etc/passwd|wc -l`-1])p" /etc/passwd

#只显示非#开头的行
[root@ubuntu2204 ~]# sed -n '/^#/!p' /etc/fstab

#不显示注释行和空行
[root@ubuntu2204 ~]# sed '/^$/d;/^#/d' fstab

#替换，&表示引用前面的r..t
[root@rocky86 0723]# sed -n 's/r..t/&er/gp' /etc/passwd

#删除非1|3|5|7
[root@ubuntu2204 ~]# rm -f `ls | grep -Ev 'f-(1|3|5|7)\.txt'`
[root@ubuntu2204 ~]# rm -f `ls |sed -n '/f-[^1357]\.txt/p'

#获取分区利用率
[root@ubuntu2204 ~]# df | sed -En 's/^\/dev.* ([0-9]+)%.*/\1/p' | sort -nr

#取ip地址，先有信息再有操作会更简单，而不是根据结果过滤数据
[root@ubuntu2204 ~]# ifconfig ens33 |sed -nr "2s/[^0-9]+([0-9.]+).*/\1/p" 
10.0.0.206

#将非#开头的行加#，r支持扩展正则，与-E一样
[root@rocky86 0723]# sed -rn ‘s/^[^#]/#&/p’ fstab

#将#开头的行删除#，原内容备份
[root@rocky86 0723]# sed -ri.bak '/^#/s/^#//' fstab
```

awk

![image-20250623152344740](image-20250623152344740.png)

```shell
awk 
#常用选项
-f  #从文件中读入
-F  #指定分隔符，默认是空白符,可以指定多个
-v  #设置变量
```

```shell
#begin中拿不到FILENAME
[root@ubuntu2204 ~]# awk 'BEGIN{print FILENAME}' /etc/issue
[root@ubuntu2204 ~]# awk 'BEGIN{print FILENAME}{print "test"}END{print FILENAME}' /etc/issue
test
test
/etc/issue
---------------------------------------FS
[root@ubuntu2204 ~]# awk -v FS=":" 'BEGIN{print FS}{print $1,$1}' /etc/passwd
:
root root
daemon daemon
[root@ubuntu2204 ~]# awk -v FS=":" 'BEGIN{print FS}{print $1FS$1}' /etc/passwd
:
root:root
daemon:daemon
#使用-F选项指定
[root@ubuntu2204 ~]# awk -F: 'BEGIN{print FS}{print $1FS$1}' /etc/passwd
:
root:root
daemon:daemon

#从shell变量中获取
[root@ubuntu2204 ~]# str=":";awk -v FS=$str 'BEGIN{print FS}{print $1FS$1}' /etc/passwd
:
root:root
daemon:daemon
#-F和FS变量功能一样，同时使用后面会覆盖前面的
[root@ubuntu2204 ~]# awk -v FS=":" -F";" 'BEGIN{print FS}' /etc/passwd
;
[root@ubuntu2204 ~]# awk -F";" -v FS=":" 'BEGIN{print FS}' /etc/passwd
:

#printf C语言写法
[root@ubuntu2204 ~]# awk -F: '{printf "%-20s %10d\n",$1,$3}' /etc/passwd

#支持赋值算数比较逻辑三目运算
[root@ubuntu2204 ~]# awk 'BEGIN{i=0;print ++i,++i}'
1 2
[root@ubuntu2204 ~]# awk -v i=0 'BEGIN{print !i}'
1
[root@ubuntu2204 ~]# awk -v i=-10 'BEGIN{print !i}'
0
[root@ubuntu2204 ~]# df|awk -F"[ %]+" '/^\/dev\/sd/{$(NF-1)>10?
disk="full":disk="OK";print $(NF-1),disk}'
26 full
3 OK
1 OK
13 full

#关系表达式关系表达式，结果为“真”才会被处理
awk '1' 
awk '0'

#读取输出第二行
[root@ubuntu2204 ~]# awk 'NR==2' /etc/passwd
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
[root@ubuntu2204 ~]# awk -F: '$3>=1000' /etc/passwd

------------------------------匹配
#包含root的行，用正则匹配，正则表达式需要用/ / 来锚定开始结束
[root@ubuntu2204 ~]# awk -F: '$0 ~ /root/{print $0}' /etc/passwd
[root@ubuntu2204 ~]# awk '/root/'   /etc/passwd
#不包含root的行
[root@ubuntu2204 ~]# awk '$0 !~ /root/' /etc/passwd

-------------------------------------行范围
[root@ubuntu2204 ~]# awk 'NR>=3 && NR<6{print NR,$0}' /etc/passwd
#sed 写法
[root@ubuntu2204 ~]# sed -n '3,5p' /etc/passwd
```

## 1.5软件包管理

```shell
rpm -qa       -ivh
dpkg -V/i/l/r
yum clean all
yum makecache            apt update
list/remove/repolist/history/search
```

## 1.6磁盘管理

```shell
fdisk -l /dev/sda
for host in /sys/class/scsi_host/host*/scan; do echo "- - -" > $host; done   #scsi热插拔扫描

fdisk /dev/sda
echo -e 'n\np\n\n\n+1G\nw' | fdisk /dev/sdb
gdisk
lsblk  #列出块设备
parted -l #显示所有分区信息

mkfs.ext4/xfs  /dev/sda      创建文件系统
mount /dev/sda /sda

du -sh
free -h


dd if=/PATH/FROM/SRC of=/PATH/TO/DEST  bs=N count=N
/dev/zero 写入测试
/dev/sda  备份
mdadm               软raid
```

lvm

```go
pvs/pvdisplay/pvcreate/pvremove
vgs/vgdisplay/vgcreate/vgextend
lvs
```

## 1.7网络相关命令

```shell
#netstat 命令用于显示网络连接、路由表、接口统计等网络相关信息。
netstat - tunlp       netstat -nr  netstat -I=ens160
#ss命令用于显示Linux系统中的套接字（socket）统计信息
ss -tunlp
#lsof 命令用于列出当前系统打开的文件及其关联的进程信息。
lsof -i :80 
```



```shell
route -n

ip route add/del via gw                               flush/不要用
#为不同的路由规则采用策略
ip route add default via 10.0.0.2 dev eth0 table rule1
ip route add default via 10.0.0.2 dev ens224 table rule2

ip link set ens160 up/down
ip address add/del 10.0.0.110/24 dev ens160

nmcli con show/del          device up/down        reload
```

tcpdump

```shell
tcpdump -D       #列出系统上所有可用于捕获数据包的网络接口
tcpdump -c 1      #指定检测数据包的数量

tcpdump -i ens160

#host监听特定主机，双向数据包
tcpdump 无/src/dst host 10.0.0.100
tcpdump ip host 10.0.0.12 and 10.0.0.13

tcpdump port 3000


#在 eth0 网络接口上捕获从 10.0.0.6 发送到 10.0.0.7 的所有ICMP数据包，不进行地址或端口的反向查找。现实还是问AI吧
tcpdump -i eth0  -nn icmp and src host 10.0.0.6 and dst host 10.0.0.7

#数据包保存   #抓出来给 wireshark分析
tcpdump tcp -i eth0 -t -s 0 -c 100 and dst port ! 22 and src net 10.0.0.0/24 -w ./target.cap          
```

nmap网络探测，安全审核

```shell
nmap 10.0.0.10-15

nmap -i hosts.txt
#指定网段扫描
nmap 10.0.0.0/24

nmap -p22,80,3306 10.0.0.12

#全部
nmap -A 10.0.0.12
```

nc

```shell
端口侦听：nc可以作为server以TCP或UDP方式侦听指定端口。
端口扫描：nc可以作为client发起TCP或UDP连接，进行端口扫描。
文件传输：可以在机器之间方便地传输文件，无需使用scp和rsync等工具，从而避免了输入密码的操作。
网络测速：通过传输文件的方式，可以测试两台机器之间的网络速度。

nc -vl 8888                                     >file.txt
nc -vl 10.0.0.12:8888                           <file.txt
```

## 1.8进程相关命令

进程由程序、数据和进程控制块（Program Control Block，PCB）三部分组成。

程序是进程要执行的指令集合，就是顺序执行的代码

数据是进程在执行过程中需要处理的信息，

进程控制块则包含了进程的各种信息和控制信息，

如进程标识符（PID）、状态、优先级、程序计数器、寄存器集合等。

```shell
pstree -p |grep nginx  #大括号括起来的为线程，没有括号的为进程

ls /proc/PID/       exe or fd...      #查看进程相关信息文件

sysctl -a | grep overcommit_memory  #内存超配参数
```



```shell
pstree -p |grep nginx
ps -aux~ps -ef
ps -auxf
ps axo %mem --sort -%mem
ps aux k -%cpu
pidof nginx
fuser /var/log/nginx/access.log
pgrep -a nginx    #ps pidof pgrep 都是为了找到PID，不用深入

top后输入M,P,T 按内存/cpu/运行时间排序
htop#主要优点在交互,非重点

vmstat 1
lsof :80
lsof /var/log/messages    #查看当前哪个进程正在使用此文件
```

```shell
uptime #负载    平均一个u不大于3
mpstat -P 0/1/2/3/ALL#多核监控            systat
iostat
iotop

iftop   nload   nethogs    iptraf-ng
dstat    glances   cockpit
```



```shell
swapoff -a #禁用交换分区内存

free -h

释放页面缓存（pagecache）
echo 1 > /proc/sys/vm/drop_caches

释放目录项缓存（dentries）和索引节点缓存（inodes）
echo 2 > /proc/sys/vm/drop_caches

释放页面缓存、目录项缓存和索引节点缓存:
echo 3 > /proc/sys/vm/drop_caches
```

```shell
command & #后台运行但是还是与终端相关
nohup command &/dev/null &

bg/fg
kill/killall/pkill

并行：command1 & command2 & command3 &
```

计划任务

```go
at
crontab -l/e
```

## 1.9服务管理及内核管理

```go
systemctl
/usr/lib/systemd/system/
/lib/systemd/system/
/etc/systemd/system/
```

内核管理

```shell
lsmod |grep ipip         #如隧道网络
modinfo ipip
modprobe ipip      #自动加载模块

```

内核参数

```shell
/proc/sys/
/etc/sysctl.conf
/etc/sysctl.d/*.conf
/usr/lib/sysctl.d/*.conf 
/lib/sysctl.d/*.conf

sysctl -a/p/w
sysctl net.ipv4.ip_forward

vim /etc/sysctl.conf    #直接/搜索要改的直接改
```

## 1.10服务相关命令

### 1.10.1DNS相关命令

```shell
#网卡配置
vim /etc/resolv.conf#配置文件，临时，长久还是在网卡配置那配和全局那配置       
/etc/systemd/resolved.conf    #全局DNS
nameserver 114.114.114.114 / 223.5.5.5 / 223.6.6.6 / 8.8.8.8
/etc/hosts #本机域名解析


#dns缓存
nscd -g   #查看
nscd -i hosts   #清除   resolvectl flush-caches
resolvectl status
```

```shell
#dns检测工具     提示 aa 即权威应答
dig www.baidu.com +trace        #域名信息查询工具          bind-utils
dig www.baidu.com -b#-b指定客户端
dig -x ip #反向解析，没啥用

host www.baidu.com       #-t A类型
host 114.116.196.150

nslookup www.baidu.com 223.5.5.5
nslookup -type=cname www.baidu.com

rndc  whois
```

```shell
#dns
named默认会占用TCP和UDP的53端口， 953是给rndc管理工具使用的
/etc/named.conf   /etc/bind/named.conf
rndc reload magedu.com
rndc flush
rndc retransfer  magedu.com#辅助DNS服务器拉数据
```

### 1.10.2加密安全与时间同步

```shell
echo -n "123456" | base64          #加密      -d解密

```

openssl

```powershell
/etc/pki/tls/openssl.cnf
/etc/ssl/openssl.cnf

openssl dgst = sha256sum
#默认 md5
[root@ubuntu ~]# openssl passwd 123456
[root@ubuntu ~]# md5sum /etc/shadow
3edae07c5e4d49e08cae2e1eeb3bd258  /etc/shadow

实现秘钥对
#生成私钥
[root@ubuntu ~]# openssl genrsa -out test.key
 #从指定私钥提取出公钥
[root@ubuntu ~]# openssl rsa -in test.key -pubout -out test.pubkey

自建CA
mkdir -pv /etc/pki/CA/{certs,crl,newcerts,private}
cd /etc/pki/CA/
私钥
openssl genrsa -out private/cakey.pem 2048
自签名，填写信息
openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -days3650 -out /etc/pki/CA/cacert.pem
查看证书
openssl x509 -in /etc/pki/CA/cacert.pem -noout -text
证书签发：私钥++签名请求+证书生成
```

ssh服务

```powershell
openssh-server
/etc/ssh/sshd_config
生成SSH密钥对~/.ssh/
ssh-keygen
使用ssh-copy-id将公钥复制到远程主机
ssh-copy-id user@remote_host               查看~/.ssh/authorized_keys

多机互通（同一网段内网可以用，但是还是最好不要用）
ssh-keygen
ssh-copy-id 127.1
scp -r .ssh 10.0.0.xxx:/root/

远程连接：ssh root@10.0.0.12
远程执行：ssh root@10.0.0.12 "执行命令"

远程传输：【关于目录的传输用-r】
		scp 本地文件 root@10.0.0.12:远程目录
		scp root@10.0.0.12:远程文件 本地目录
同步文件：【关于目录的传输用-r 】
		rsync -av 本地文件 root@10.0.0.12:远程目录
		rsync -av root@10.0.0.12:远程文件 本地目录
```

sudo

```shell
#主配置文件
/etc/sudo.conf
 #授权规则配置文件
/etc/sudoers
/etc/sudoers.d/*

/var/db/sudo
/var/log/auth.log #ubuntu

su - #切用户
visudo -c   #语法检查
sudo -u sswang -l #-l查看该用户的规则
```

时间

```shell
ntp #centos8没了
/etc/ntp.conf
chrony
/etc/chrony/chrony.conf 或 /etc/chrony.conf
server ntp.aliyun.com iburst
server ntp.tencent.com iburst
server ntp.ntsc.ac.cn iburst

ntpdate ntp.aliyun.com
chronyc makestep   #强制同步外网时间

timedatectl set-time "2042-10-15 00:00:00"
```

### 1.10.3日志服务

```go
/etc/rsyslog.d/
journalctl -n 5 查看最后5条⽇志
journalctl -p err 查看err类型的⽇志
journalctl 
journalctl -k      查看内核日志
journalctl -u nginx.service
journalctl -xe
```

### 1.10.4NFS

```powershell
rpcbind  nfs-utils #rocky
nfs-kernel-server nfs-common  #ubuntu

rpcinfo -p 10.0.0.13#注册的rpc服务

cat /etc/exports
修改配置文件后，加载配置
root@ubuntu24:~# exportfs -r
查看加载配置的效果
root@ubuntu24:~# exportfs -v
卸载操作
root@ubuntu24:~# exportfs -au

mount nfs主机地址:/data/dira /data/dir1

showmount -e
```

### 1.10.5实时同步

