[TOC]

# web服务

## 1.http协议

HTTP：（HyperText Transfer Protocol）超文本传输协议

HTTP 是一个工作在应用层的通信协议，它允许将超文本标记语言（HTML）文档从 WEB 服务器传送到 客户端的浏览器

HTTP 不是一个孤立的协议： 在互联网世界里，HTTP 通常跑在 TCP/IP 协议栈之上，依靠 IP 协议实现寻址和路由、TCP 协议实现可 靠数据传输、DNS 协议实现域名查找、SSL/TLS 协议实现安全通信。此外，还有一些协议依赖于HTTP， 例如 WebSocket、HTTPDNS 等。这些协议相互交织，构成了一个协议网，而HTTP 则处于中心地位

### 1.1HTTP 协议相关概念和技术

URI：（Uniform Resource Identifier），统一资源标识符，是一个用来唯一标识互联网上某一特定资源 的字符串 

WEB 上的可用的每种资源，HTML文档，图片文件，音视频文件，压缩包等，都可以用一个全网唯一的  URI 来标识出来，该标识充许用户对任何资源通过特定的协议进行交互操作

简单来说，URI 是抽象的定义，不管用什么方法表示，只要能定位一个资源，就叫 URI

URL：（Uniform Resource Locator），统一资源定位符 

在早期的设计中，用来定位资源的方式有两种，用地址定位（URL）和 用名称定位（URN），不管用哪 种方式定位，只要能保证全网唯一即可

![image-20250227131743406](image-20250227131743406.png)

URN：（Uniform Resource Name），统一资源名称

### 1.2网站流量指标

UV：（unique visitors），独立访客量，独立访问者数量，一天内来自相同客户端的访问只计算一 次 

PV：（page views），页面浏览数量，网站点击量，访客每打开一个页面或刷新一次页面都计算一 次， 

IP：独立IP数量，一天内来自相同IP地址的客户端的访问只计算一次，是衡量网站流量的重要指标

### 1.3浏览器访问网站的过程

![image-20250227132410265](image-20250227132410265.png)

一个页面通常有多个资源组成，浏览器打开一个页面，通常要发起多次请求，分别加载不同的资源

### 1.4http请求报文

![image-20250227132710050](image-20250227132710050.png)

![image-20250227132734979](image-20250227132734979.png)

```bash
curl -v http://www.baidu.com
```

### 1.5http响应状态码



![image-20250227132924772](image-20250227132924772.png)

### 1.6COOKIE 和 SESSION

HTTP 是一种无状态协议，这意味着每个HTTP请求都是相互独立的，服务器在处理请求时不会保留先前 请求的任何状态信息，每个请求都是独立的、不相关的操作。 

这无状态的特性有助于简化协议的设计和实现，同时也使得它更具可伸缩性，每个请求都包含所有必要 的信息，而服务器无需维护每个客户端的状态，从而降低了服务器的负担。 

如果客户端需要在多次请求之间保持状态，通常会使用一些机制，如Cookie或Session。 

Cookies 和 Sessions 都是用于在Web应用程序中管理用户状态的机制，它们的作用主要涉及用户身份验 证、跟踪会话信息以及存储用户偏好等方面

#### Cookie

Cookie 是一小段存储在用户计算机上的数据，由服务器通过 HTTP 协议发送给用户的浏览器，然后浏览 器将其保存。每次用户访问同一站点时，浏览器都会将相应的 Cookie 发送回服务器，从而实现在客户 端和服务器之间存储和传递信息的功能。Cookies 通常包含一些键值对，用于存储少量文本数据，例如 用户的身份认证信息、首选语言、个性化设置等



#### Session

Session 是服务器端的一种机制，用于在用户和服务器之间存储信息。与 Cookie 不同，Session 数据并 不直接存储在用户计算机上，而是存储在服务器上。通常，服务器会为每个用户创建一个唯一的会话标 识符（Session ID），该标识符通过 Cookie 或者 URL 参数的形式发送给用户。在服务器端，与每个会 话相关的数据都会被存储，这样在用户的不同请求之间可以保持状态。 Sessions 通常用于存储用户的登 录状态、购物车内容、权限信息等

#### Cookie 和 Session 的经典使用场景（具体见项目演示）

1. 客户端使用用户名和密码登录网站 
2. 服务端在验证客户端登录凭证后，生成当前用户唯一的 session 数据保存在服务端，并将该  session id 下发给客户端 
3. 客户端接收到会话ID后保存在本地的Cookie 中，下次刷新页面，会将该会话ID发送到服务端，服 务端验证SESSION 信息，从而显示该客户端的登录状态

![image-20250227133802994](image-20250227133802994.png)

![image-20250227133824055](image-20250227133824055.png)

![image-20250227222259947](image-20250227222259947.png)

## 2.网络IO

![image-20250228221126093](image-20250228221126093.png)

**同步和异步** 

同步和异步关注的是消息的通信机制，即调用者在等待一件事情的处理结果时，被调用者是否提供完成 状态的通知

同步：sychronous，被调用者并不提供事件的处理结果相关的通知消息，需要调用者主动谒问事 件是否处理完成 

异步：asynchronous，被调用者通过状态，通知或者回调机制主动通知发起调用者相关的运行状 态

**阻塞和非阻塞**

阻塞和非阻塞关注的是调用发起者在等待结果返回之前所处的状态

阻塞：blocking，指IO操作需要彻底完成后才返回到用户空间，调用结果返回之前，调用者被挂 起，干不了别的事情。 

非阻塞：nonblocking，指IO操作被调用后立即返回给用户一个状态值，而无需等到IO操作彻底完 成，在最终的调用结果返回之前，调用者不会被挂起，可以去做别的事情。

![image-20250228221607241](image-20250228221607241.png)

**阻塞 IO（blocking IO）**

![image-20250228225309410](image-20250228225309410.png)

用户线程通过系统调用 read 发起I/O读操作，由用户空间转到内核空间。内核等到数据包到达后，然后 将接收的数据拷贝到用户空间，完成 read 操作，用户需要等待 read 将数据读取到buffer后，才继续处 理接收的数据。整个I/O请求的过程中，用户线程是被阻塞的，**这导致用户在发起IO请求时，不能做任何 事情，对CPU的资源利用率不够**

优点：程序简单，在阻塞等待数据期间进程/线程挂起，基本不会占用 CPU 资源 

缺点：每个连接需要独立的进程/线程单独处理，当并发请求量大时为了维护程序，内存、线程切换开销 较大，apache 的 prefork 使用的是这种模式。

**非阻塞 IO（non-blocking IO）**

![image-20250228225652026](image-20250228225652026.png)

用户线程发起IO请求时立即返回，但并未读取到任何数据，用户线程需要不断地发起IO请求，直到数据 到达后，才真正读取到数据，继续执行。

轮询机制存在两个问题： 

如果有大量文件描述符都要等，那么就得一个一个的 read。这会带来大量的 Context Switch（read是 系统调用，每调用一次就得在用户态和核心态切换一次）。 

轮询的时间不好把握，这里是要猜多久之后数据才能到。等待时间设的太长，程序响应延迟就过大；设 的太短，就会造成过于频繁的重试，干耗CPU而已，是比较浪费CPU的方式，一般很少直接使用这种模 型，而是在其他IO模型中使用非阻塞IO这一特性。

**多路复用 IO（IO multiplexing）**

![image-20250228231208011](image-20250228231208011.png)

多路复用IO指一个线程可以同时（实际是交替实现，即并发完成）监控和处理多个文件描述符对应各自 的IO，即复用同一个线程 

一个线程之所以能实现同时处理多个IO，是因为这个线程调用了内核中的SELECT，POLL 或 EPOLL 等系 统调用，从而实现多路复用IO，这三个系统调用的好处就在于单个 process 可以同时处理多个网络连接 IO，其基本原理是不断的轮询所负责的所有socket，当某个socket有数据到达了，就通知用户进程。 

当用户进程调用了select，那么整个进程会被 block，而同时，kernel会 监视 所有 select 负责的  socket，当任何一个 socket 中的数据准备好了，select 就会返回。这个时候用户进程再调用 read 操 作，将数据从 kernel 拷贝到用户进程 

Apache prefork是此模式的 select，worker 是 poll 模式。

**3.2.4 信号驱动 IO（signal driven I/O， SIGIO）**

![image-20250228231430826](image-20250228231430826.png)

信号驱动I/O的意思就是进程现在不用傻等着，也不用去轮询。而是让内核在数据就绪时，发送信号通知 进程 

调用的步骤是，通过系统调用 sigaction ，并注册一个信号处理的回调函数，该调用会立即返回，然后 主程序可以继续向下执行，当有IO操作准备就绪,即内核数据就绪时，内核会为该进程产生一个 SIGIO 信 号，并回调注册的信号回调函数，这样就可以在信号回调函数中系统调用 recvfrom 获取数据，将用户进程所需要的数据从内核空间拷贝到用户空间 

此模型的优势在于等待数据报到达期间进程不被阻塞。用户主程序可以继续执行，只要等待来自信号处 理函数的通知，在信号驱动式 IO 模型中，应用程序使用套接口进行信号驱动 IO，并安装一个信号处理 函数，进程继续运行并不阻塞，当数据准备好时，进程会收到一个 SIGIO 信号，可以在信号处理函数中 调用IO操作函数处理数据 

优点：线程并没有在等待数据时被阻塞，内核直接返回调用接收信号，不影响进程继续处理其他请求， 因此可以提高资源的利用率 

缺点：信号 IO 在大量IO操作时可能会因为信号队列溢出导致没法通知

**异步 IO（Asynchronous I/O）**

![image-20250301223018943](image-20250301223018943.png)

异步IO 与 信号驱动IO最大区别在于，信号驱动是内核通知用户进程何时开始一个IO操作，而异步IO是 由内核通知用户进程IO操作何时完成，两者有本质区别 

相当于不用去饭店场吃饭，直接点个外卖，把等待上菜的时间也给省了 

相对于同步IO，异步IO不是顺序执行。用户进程进行 aio_read 系统调用之后，无论内核数据是否准备 好，都会直接返回给用户进程，然后用户态进程可以去做别的事情。等到 socket 数据准备好了，内核直 接复制数据给进程，然后从内核向进程发送通知。IO 两个阶段，进程都是非阻塞的 

信号驱动IO当内核通知触发信号处理程序时，信号处理程序还需要阻塞在从内核空间缓冲区拷贝数据到 用户空间缓冲区这个阶段，而异步IO直接是在第二个阶段完成后，内核直接通知用户线程可以进行后续 操作了 

优点：异步 IO 能够充分利用 DMA 特性，让 IO 操作与计算重叠 

缺点：要实现真正的异步 IO，操作系统需要做大量的工作，目前 Windows 下通过 IOCP 实现了真正的 异步 IO，在 Linux 系统下，Linux 2.6才引入，目前 AIO 并不完善，因此在 Linux 下实现高并发网络编 程时以 IO 复用模型模式 + 多线程任务的架构基本可以满足需求 Linux提供了AIO库函数实现异步，但是用的很少。目前有很多开源的异步IO库，例如libevent、libev、 libuv。

![image-20250301223300216](image-20250301223300216.png)

## 3.Apache

Apache 通常可以指代两个相关但不同的概念，分别是 Apache 软件基金会和 Apache HTTP Server

**Apache HTTP Server（简称Apache）** 

Apache HTTP Server 是一个开源的、跨平台的Web服务器软件，它是最著名的ASF项目之一，广泛用于 互联网上的Web服务器

```bash
https://httpd.apache.org/           
#httpd 项目网址
```

### 3.1Apache2 特点

apache2 特性 

高度模块化：core + modules 

DSO：Dynamic Shared Object 动态加载/卸载 

MPM：multi-processing module 多路处理模块

Apache2 功能 

虚拟主机：IP，Port，FQDN 

CGl：Common Gateway lnterface，通用网关接口 

反向代理 负载均衡 路径别名 

丰富的用户认证机制：basic，digest 

支持第三方模块

### 3.2Apache2 的 MPM 工作模式

**prefork 模型**

预派生模式，有一个主控制进程，然后生成多个子进程，每个子进程有一个独立的线程响应用户请求， 相对比较占用内存，但是比较稳定，可以设置最大和最小进程数，是最古老的一种模式，也是最稳定的 模式，适用于访问量不是很大的场景 

优点：工作稳定 

缺点：每个用户请求需要对应开启一个进程，占用资源较多，并发性差，不适用于高并发场景

![image-20250305150733397](image-20250305150733397.png)

**worker 模型**

一种多进程和多线程混合的模型，有一个控制进程，启动多个子进程，每个子进程里面包含固定的线 程，使用线程来处理请求，当线程不够使用的时候会再启动一个新的子进程，然后在进程里面再启动线 程处理请求，由于其使用了线程处理请求，因此可以承受更高的并发

优点：相比prefor模型，其占用的内存较少，可以同时处理更多的请求

缺点：使用keepalive的长连接方式，某个线程会一直被占据，即使没有传输数据，也需要一直等待到超 时才会被释放。如果过多的线程被这样占据，也会导致在高并发场景下的无服务线程可用。（该问题在 prefork模式下，同样会发生）

![image-20250305150811555](image-20250305150811555.png)

**event 模型**

属于事件驱动模型 (epoll)，每个进程响应多个请求，在现在版本里的已经是稳定可用的模式，它和worker模式很像，最大 的区别在于，它解决了keepalive场景下，长期被占用的线程的资源浪费问题（某些线程因为被 keepalive，空挂在哪里等待，中间几乎没有请求过来，甚至等到超时）。event MPM中，会有一个专 门的线程来管理这些keepalive类型的线程，当有真实请求过来的时候，将请求传递给服务线程，执行完 毕后，又允许它释放。这样增强了高并发场景下的请求处理能力

优点：单线程响应多请求，占据更少的内存，高并发下表现更优秀，会有一个专门的线程来管理 keepalive类型的线程，当有真实请求过来的时候，将请求传递给服务线程，执行完毕后，又允许它释放

缺点：没有线程安全控制

![image-20250305151020526](image-20250305151020526.png)

### 3.3Apache2 安装配置与使用

```bash
#ubuntu 中安装
[root@ubuntu ~]# apt update;apt install apache2 -y
[root@ubuntu ~]# dpkg -l apache2
 
 #rocky9 中安装
[root@rocky ~]# yum install httpd -y
[root@rocky ~]# rpm -q httpd

[root@ubuntu ~]# ss -tnlp  | grep 80
#一个父进程，两个子进程
[root@ubuntu ~]# lsof -i:80

#此命令也可以查看
[root@ubuntu ~]# pstree -p

#自带的控制脚本
[root@ubuntu ~]# which apachectl 
/usr/sbin/apachectl

[root@ubuntu ~]# ll /usr/sbin/apache*
```

**配置**

Apache2 的配置主要分为三部份，分别是全局配置，虚拟主机配置，模块配置，这些配置项分散在不同 的目录和文件中，在主配置文件中以文件包含的形式引用它们

### 3.4**配置**

**主配置**

主配置文件中的指令对整个服务器都生效，如果只想改变某一部分的配置，则可以把指令嵌入到配置段 中，这样就可以限制指令的作用域为文件系统中的某些位置或特定的URL，这些配置段还可以进行嵌 套，以进行更精细的配置

**Apache2 还具备同时支持多个站点的能力，称为虚拟主机**，配置段中的指令仅对该段中 的特定站点(虚拟主机)有效

![image-20250305152439700](image-20250305152439700.png)

常用配置项（作用域列说明：S 代表 server config，V 代表 virtual host，D 代表 directory，H 代表  .htaccess）

![image-20250305152750899](image-20250305152750899.png)

![image-20250305152826527](image-20250305152826527.png)

![image-20250305152852735](image-20250305152852735.png)

![image-20250305152944459](image-20250305152944459.png)

配置全局默认主页有优先级，最左边最优先

```bash
#重载
[root@ubuntu ~]# systemctl reload apache2.service
```

**Listen 配置监听IP和端口**

![image-20250305153702644](image-20250305153702644.png)

![image-20250305153844421](image-20250305153844421.png)

**配置数据压缩**

启用 apache2 的数据压缩功能能减少网络IO的数据量，提高服务器的网络吞吐能力

默认己开启数据压缩

```bash
#需要模块支持，默认己加载
[root@ubuntu ~]# apache2ctl -M | grep deflate
 deflate_module (shared)
```

![image-20250305154214783](image-20250305154214783.png)

在浏览器中测试，CSS，JS 被压缩，JPG没有被压缩，除了在浏览器中查看外，还可以在access日志中查 看

![image-20250305154238287](image-20250305154238287.png)

![image-20250305154252295](image-20250305154252295.png)

```bash
#curl 默认不压缩，是否需要压缩要客户端协商
[root@ubuntu ~]# curl -v 127.1/test.js >/dev/null
#wget 默认也不压缩
[root@ubuntu ~]# wget 127.0.0.1/test.js
#curl 启用压缩
[root@ubuntu ~]# curl --compressed -v 127.1/test.js >/dev/null
```

**ServerTokens 配置响应头中的Server 字段信息** 

ServerTokens 选项用来配置 HTTP 响应头中的 Server 字段信息，其取值如下

![image-20250305154622376](image-20250305154622376.png)

![image-20250305154718027](image-20250305154718027.png)

**配置持久连接**

持久连接是指，建立连接后，每个资源获取完后不会立即断开连接，而是保持一段时间后断开，默认是 开启了持久连接

配合持久连接的有一个时间限制选项，单位为秒，apache2.4之后支持毫秒级设置 对并发量大的服务器，持久连接会使有些请求得不到响应

![image-20250305154819159](image-20250305154819159.png)

定义路径别名 

Alias 指令用于在URL 和文件系统之间实现映射，使不在 DocumentRoot 目录下的内容也能成为项目的 一部份

![image-20250305155859542](image-20250305155859542.png)

![image-20250305155935956](image-20250305155935956.png)

#### 3.4.1访问资源控制

![image-20250305160413068](image-20250305160413068.png)

![image-20250305160439029](image-20250305160439029.png)

![image-20250305160448029](image-20250305160448029.png)

![image-20250305160458812](image-20250305160458812.png)

![image-20250305160540922](image-20250305160540922.png)

**控制特定主机的访问**

![image-20250305160628438](image-20250305160628438.png)

虽然 .htaccess 文件可以分别为不同的目录配置规则，但在实践中尽量避免使用

#### 3.4.2日志配置

![image-20250305160907697](image-20250305160907697.png)

![image-20250305160916012](image-20250305160916012.png)

自定义访问日志格式并使用

```bash
#在/etc/apache2/apache2.conf 中增加日志格式定义
LogFormat "%h %l %u test-format %{User-agent}i" test-format
 
 #修改 /etc/apache2/conf-enabled/other-vhosts-access-log.conf
 CustomLog ${APACHE_LOG_DIR}/other_vhosts_access.log test-format
 
 #重载，测试，查看日志
[root@ubuntu ~]# tail -1 /var/log/apache2/other_vhosts_access.log
 127.0.0.1 - - test-format curl/7.81.0
```

#### 3.4.3状态页配置

![image-20250305161134077](image-20250305161134077.png)

#### 3.4.4虚拟主机配置

多虚拟主机的实现方式 

基于端口实现：用不同的端口标识不同的虚拟主机 

基于IP实现：用不同的IP地址标识不同的虚拟主机 

基于域名实现：用不同的域名标识不同的虚拟主机

![image-20250305161246358](image-20250305161246358.png)

![image-20250305161350584](image-20250305161350584.png)

![image-20250305161420162](image-20250305161420162.png)

```bash
 [root@ubuntu ~]# apachectl -t
Syntax OK
 [root@ubuntu ~]# systemctl reload apache2
  #查看监听端口
[root@ubuntu ~]# ss -tnlp | grep apache2
```

![image-20250305161551980](image-20250305161551980.png)

![image-20250305161633541](image-20250305161633541.png)

![image-20250305161722936](image-20250305161722936.png)

![image-20250305161741424](image-20250305161741424.png)

![image-20250305162820152](image-20250305162820152.png)

![image-20250305163003779](image-20250305163003779.png)

![image-20250305163101998](image-20250305163101998.png)

![image-20250305163139851](image-20250305163139851.png)

#### 3.4.5错误页面配置

在 HTTP 协议中，响应报文都有相应的状态码，其中 200 表示正确返回，其它状态码都表示错误，可以 在Apache2 中设置根据不同的状态码设置不同的错误页面，也可以在虚拟主机的配置中为每个网站设置 不同的错误页面

![image-20250305163249434](image-20250305163249434.png)

![image-20250305163300161](image-20250305163300161.png)

![image-20250305163316522](image-20250305163316522.png)

![image-20250305163348368](image-20250305163348368.png)

#### 3.4.6访问验证配置(不用)

![image-20250305163519876](image-20250305163519876.png)

![image-20250305163551182](image-20250305163551182.png)

```bash
 #默认己经加载了 auth_basic 认证模块
[root@ubuntu ~]# apachectl -M | grep auth_
 auth_basic_module (shared)
```

![image-20250305163619058](image-20250305163619058.png)

#### 3.4.7模块配置和工作模式配置

```bash
#列出所有己加载的模块，包括核心模块和用配置文件加载的模块
[root@ubuntu ~]# apachectl -M
#所有模块文件
[root@ubuntu ~]# ll /usr/lib/apache2/modules/*so | wc -l
 118
```

![image-20250305163946533](image-20250305163946533.png)

![image-20250305163953710](image-20250305163953710.png)

![image-20250305164227588](image-20250305164227588.png)

##### 模式配置

![image-20250305164321917](image-20250305164321917.png)

![image-20250305164334579](image-20250305164334579.png)

![image-20250305164342108](image-20250305164342108.png)

![image-20250305164407728](image-20250305164407728.png)

![image-20250305164420772](image-20250305164420772.png)

### 3.5.Apache2 实现 Https 访问

#### **Apache2 中的默认 SSL 配置**

```bash
#ssl 功能需要相关模块支持，默认没有加载此模块
[root@ubuntu ~]# apachectl -M | grep ssl
```

![image-20250305174751811](image-20250305174751811.png)

![image-20250305174835909](image-20250305174835909.png)

![image-20250305180050698](image-20250305180050698.png)

![image-20250305180106436](image-20250305180106436.png)

![image-20250305180145564](image-20250305180145564.png)

![image-20250305180201876](image-20250305180201876.png)

#### 自签证书实现多域名 Https

#### 在公有云中配置 Https 域名

![image-20250305180307359](image-20250305180307359.png)

### 3.6Apache2 中实现URL重定向

URL 重定向的分类

301（Moved Permanently）：永久重定向，服务器向客户端发送指令，告诉客户端当前请求的  URL 被永久的重定向到其它的URL，客户端下次请求该资源应该使用新的 URL 

302（Moved Temporarily）：临时重定向，服务器向客户端发送指令，告诉客户端当前请求的  URL 被临时重定向到其它的URL，客户端下次请求该资源还可以继续使用原来的 RUL

#### **URL 重定向的实现**

![image-20250305180547182](image-20250305180547182.png)

![image-20250305180610781](image-20250305180610781.png)

![image-20250305180641519](image-20250305180641519.png)

#### HSTS 安全重定向

**HSTS：HTTP严格传输安全（HTTP Strict Transport Security）**

HSTS 是一种网站用来声明他们只能使用安全连接（HTTPS）访问的方法，如果一个网站声明了 HSTS 策 略，浏览器必须拒绝所有的 HTTP 连接并阻止用户接受不安全的 SSL 证书。 目前大多数主流浏览器都支 持 HSTS

**HSTS 工作原理** 

客户端在通过URL 请求某个资源的时候，如果服务端返回重定向状态码，则客户端需要重新发起 HTTPS  连接，如果服务端有配置 HSTS 功能，则服务端返回的内容中将明确声明，此网站的 HTTP 连接完全是 不被允许的，如果客户端接收到使用 HTTP 传输的资源，则必须使用HTTPS 请求替代，如果HTTPS不可 用，则终止该资源连接 

另外，浏览器在遇到无效的 HTTPS 证书时（过期，自签名，由未知 CA 签名等），将阻止建立连接，并 显示一个提示页面，但该页面可以手动确认后继续访问，但如果服务端配置了 HSTS功能，客户端将无 法手动绕过告警，若要访问该站点，必须从浏览器内部的 HSTS 列表中删除该站点

**HSTS 与服务端HTTPS重定向的区别** 

服务端 HTTPS 重定向是指客户端每次访问 HTTP 协议的 URL 资源，然后服务端返回301或302，客户端 再去请求 HTTPS 资源 

HSTS 是指客户端首次访问 HTTP 协议的 URL 资源，然后服务端返回带有 HSTS 的重定向头，在 HSTS  规定的有效期内，下次浏览器再次访问该网站的 HTTP 协议的资源时，浏览器将直接换成 HTTPS 协议再 去访问

**HSTS 预加载列表（hsts preload list）** 

HSTS 预加载列表是 Chromium 项目维护一个使用 HSTS 的网站列表，该列表通过浏览器发布。 如果你 把你的网站添加到预加载列表中，浏览器会首先检查内部列表，这样你的网站就永远不会通过 HTTP 访 问，甚至在第一次连接尝试时也不会。 这个方法不是 HSTS 标准的一部分，但是它被所有主流浏览器 （Chrome，Firefox，Safari，Opera，IE11，Edge）所支持 为了提高安全性，浏览器不能访问或下载 预加载列表（preload list）， 它作为硬编码资源（hard coded resource）和新的浏览器版本一起分发。 这意味着结果出现在列表中需要相当长的时间，而域从 列表中删除也需要相当长的时间

### 3.7LAMP架构

![image-20250305181816462](image-20250305181816462.png)

LAMP 是中小型动态网站的常见组合，虽然这些开放源代码程序本身并不是专门设计成同另几个程序一 起工作的，但由于它们各自的特点和普遍性，使得这个组合在搭建动态网站这一领域开始流行起来

##### 在 Apache2 中配置 PHP 支持

**PHP 运行方式说明**

PHP 是一种脚本语言，PHP 文件可以看成是和 shell 脚本一样的代码片段，可以直接在命令行执行 如果是用 PHP 语言开发的动态网站，则需要通过浏览器进行访问，那么在服务端，需要 WEB SERVER  配合 PHP 一起来实现动态网站的解析功能

任何一种 WEB 服务器（Apache，Nginx，IIS 等）都是被设计出来提供 WEB 服务的，仅仅只能处理静 态资源（html 文件，css 文件，js 文件，图片文件等），因此 WEB 服务器并不能处理任何动态脚本文 件（php，py 等），需要由 PHP 处理器来解析 WEB 应用中的 PHP 代码，并将执行结果传递给WEB服 务器，WEB 服务器再将此结果当成静态资源发送给客户端用户

在 Apache2 中，主要有两种方式实现 PHP 网页文件的动态解析

**模块加载运行方式（mod_php）**

PHP 处理器（解释器）以模块的形式加载到 Apache2 中，成为 Apache2 的内置功能，当客户端请求  PHP 动态资源时，由 Apache2 中的内置模块完成 PHP 动态代码的解析，再将运行结果返回给客户端

使用这种方式的优点是性能相对较好，因为 PHP 代码的执行与 WEB 服务器在同一进程中，避免了额外 的进程通信开销，缺点是可伸缩性较差，因为 Apache2 和 PHP 解析器是一个整体，无法拆分

**FastCGI 运行方式**

FastCGI 是一种通信协议，允许 Web 服务器与外部的 FastCGI 进程（例如 PHP 解释器）进行通信，当  Apache2 收到 PHP 动态资源请求的时候，就将此解析请求转发给 FastCGI 进程，由 FastCGI 进程负责 解析PHP，再将解析结果回传给 Apache2，然后 Apache2 再将结果返回给客户端 当使用 FastCGI 时，每个请求都可以由一个独立的外部 FastCGI 进程处理，这提供了更好的可伸缩性， 因为 FastCGI 进程可以独立于 Web 服务器运行，但需要消耗一些额外的通信开销

![image-20250305182219965](image-20250305182219965.png)

选择使用 mod_php 还是 FastCGI 取决于特定的需求和性能目标，在某些情况下，特别是在单一服务器 环境中，mod_php 可能更简单和高效，在高度可伸缩的环境中，或者如果你希望将 PHP 进程与 Web  服务器分离，使用 FastCGI 可能更合适

**CGI 和 FastCGI**

CGI（Common Gateway Interface）：通用网关接口

FastCGI （Fast Common Gateway Interface）：快速通用网关接口

FastCGI 是 CGI 的改进版，同样也是一种接口协议，无关于编程语言，主要改进是将 CGI 解释器进程保 持在内存中并因此获得较高的性能

**php-fpm**

PHP-FPM（PHP FastCGI Process Manager）：PHP-FastCGI 进程管理器，为了更好的管理 PHP FastCGI 而实现的一个程序

##### 以模块形式配置 PHP

##### 以 PHP-FPM 形式配置 PHP

**PHP-FPM 支持两种不同的监听的方式：Unix 套接字（Socket）和 TCP/IP 监听**

这两种监听方式各有优缺点，在选择监听方式时，要根据具体的部署环境来考虑，如果在同一台服务器 上部署 WEB SERVER 和 PHP-FPM ，Unix 套接字可能是一个更好的选择。如果需要分布式环境或负载均 衡，TCP/IP 地址和端口可能更合适，在使用TCP/IP 监听的时候，注意 Apache2 中配置的文件路径要和  PHP-FPM 服务器上的文件路径对齐

### 3.8实现基于 wordpress 的博客系统

WordPress 是使用 PHP 语言开发的博客平台，用户可以在支持 PHP 和 MySQL 数据库的服务器上架设 属于自己的网站。也可以把 WordPress当作一个内容管理系统（CMS）来使用

#### Opcache 实现 PHP 加速

对于 PHP 这样的解释型语言来说，每次的运行都会将所有的代码进行一次加载解析，这样一方面的好处 是代码随时都可以进行热更新修改，因为我们不需要编译。但是这也会带来一个问题，那就是无法承载 过大的访问量。 

OPcache 通过将 PHP 脚本预编译的字节码存储到共享内存中来提升 PHP 的性能， 存储预编译字节码的 好处就是省去了每次加载和解析 PHP 脚本的开销。

## 4.Nginx

### 4.1Nginx 架构和工作模型

![image-20250305232415439](image-20250305232415439.png)

![image-20250305232523103](image-20250305232523103.png)

![image-20250305232701863](image-20250305232701863.png)

**Master 进程**

启动过程： 当你启动Nginx时，Master进程首先启动。它会读取配置文件，初始化全局资源，并创 建指定数量的Worker进程

创建 Worker 进程： Master进程会创建Worker进程来处理实际的客户端请求。每个Worker进程 都是一个独立的进程，它们之间相互独立，互不影响 

管理 Worker 进程： Master进程负责监控Worker进程的状态。如果某个Worker进程异常退出 （比如发生错误），Master进程会重新启动一个新的Worker进程，以确保服务的可用性

**Worker 进程**

处理客户端请求： Worker进程是实际处理客户端请求的进程。每个Worker进程是单线程的，但通 过多进程的方式，Nginx能够同时处理多个请求，实现高并发 

事件驱动和异步处理： Worker进程采用事件驱动的异步模型。它使用事件循环和非阻塞I/O操作， 允许在不同的连接之间高效切换，以处理大量并发请求 

负载均衡： 如果配置了负载均衡，多个Worker进程可以分担负载，均衡地分配请求，提高系统的 整体性能

**Master 进程 与 Worker 进程的联系**

在运行时，Master 进程负责监控 Worker 进程的状态，如果某个 Worker 进程异常退出，Master 进程 会重新启动一个新的 Worker 进程，确保服务的稳定性。Master 进程和 Worker 进程之间通过信号进行 通信，例如在重新加载配置时，Master 进程会向 Worker 进程发送信号，通知它们重新加载配置而无需停止服务

这种Master-Worker模型使Nginx在高并发环境下表现出色，同时能够保持稳定性和可扩展性。Master 进程和Worker进程之间的协同工作是Nginx架构的关键之一

```bash
#nginx 中的 master 进程和 worker 进程
[root@ubuntu ~]# ps aux | grep nginx 
```

### 4.2Nginx模块

Nginx的模块化设计使得用户可以根据需求选择并集成不同类型的模块，从而定制化地配置和扩展Nginx 服务器的功能 

Nginx 模块可以分为两大类：核心模块和第三方模块

**核心模块（Core Modules）** 

Nginx 的核心模块主要有三部份，分别是 

Events Module： 处理与事件相关的操作，如连接的接受和关闭。包括事件驱动机制等 HTTP Module： 处理 HTTP 请求和响应，包括配置 HTTP 服务器、反向代理和负载均衡等 Mail Module：提供邮件代理服务顺的功能，支持 IMAP，POP3等协议

基中 HTTP 模块又包含以下几部份 

Core Module： 包含基本的 HTTP 功能，如配置服务器块、location 块等 

Access Module： 处理访问控制，包括允许或拒绝特定的 IP 地址或用户 

FastCGI Module： 支持 FastCGI 协议，用于与 FastCGI 进程通信 

Proxy Module： 提供反向代理功能，用于将请求代理到后端服务器 

Upstream Module： 用于定义负载均衡的后端服务器组

**第三方模块（HTTP Modules）**

Nginx提供了一套模块化的架构，允许开发者编写自定义的模块来扩展功能。这些第三方模块可以包括 但不限于以下几类

HTTP 模块： 扩展HTTP模块的功能，添加自定义的处理逻辑 

Filter 模块： 提供对HTTP请求和响应进行过滤的功能 

Load Balancer 模块： 实现负载均衡策略 

Access Control 模块： 控制对资源的访问权限 

Security 模块： 提供安全性增强的功能，如防火墙、DDoS防护等 

Authentication 模块： 处理用户认证逻辑

### 4.3Nginx安装与使用

#### 4.3.1Nginx 安装

Nginx 一般可以使用 apt/yum 来安装二进制包，如果需要使用特定的功能模块，也可以使用源码安装， 使用 yum/apt 安装的时候，只能安装操作系统发行版厂商己经提交到仓库中的版本，如果需要安装更新 的版本或历史版本，可自行配置官方仓库，然后进行安装

```bash
#ubuntu2204 中可安装的 nginx
[root@ubuntu ~]# apt list nginx -a
[root@ubuntu ~]# apt info nginx

#rocky9.2 中可安装的 nginx
 [root@rocky ~]# yum list nginx
 [root@rocky ~]# yum list nginx
 
 #配置文件，默认网站根目录文件，模块目录等
[root@ubuntu ~]# dpkg -L nginx-common
```

**Nginx 源码编安装**

```bash
#安装编译工具链
[root@ubuntu ~]# apt update
 [root@ubuntu ~]# apt install -y make gcc libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev
 #创建运行用户
[root@ubuntu ~]# useradd -r -s /usr/sbin/nologin nginx
 #下载最新版源码并解压
[root@ubuntu ~]# wget https://nginx.org/download/nginx-1.22.1.tar.gz
 [root@ubuntu ~]# tar xf nginx-1.22.1.tar.gz
 [root@ubuntu ~]# cd nginx-1.22.1/
 
 #编译安装
[root@ubuntu nginx-1.22.1]# ./configure --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_modu

[root@ubuntu nginx-1.22.1]# make && make install
#修改目录属主属组并查看
[root@ubuntu nginx-1.22.1]# chown -R nginx.nginx /apps/nginx/
[root@ubuntu nginx-1.22.1]# ls -l /apps/nginx/

#查看版本
[root@ubuntu nginx-1.22.1]# nginx -v
```

![image-20250310222020806](image-20250310222020806.png)

##### 启动配置

```bash
#先停止，直接启动不能用systemctl 管理
[root@ubuntu ~]# nginx -s stop
 #创建PID 目录
[root@ubuntu ~]# mkdir /apps/nginx/run
 [root@ubuntu ~]# chown -R nginx.nginx /apps/nginx/run
 #创建nginx服务脚本
[root@ubuntu ~]# cat /usr/lib/systemd/system/nginx.service
[Unit]
 Description=nginx - high performance web server
 Documentation=http://nginx.org/en/docs/
 After=network-online.target remote-fs.target nss-lookup.target
 Wants=network-online.target
 [Service]
 Type=forking
 PIDFile=/apps/nginx/run/nginx.pid
 ExecStart=/apps/nginx/sbin/nginx -c /apps/nginx/conf/nginx.conf
 ExecReload=/bin/kill -s HUP $MAINPID
 ExecStop=/bin/kill -s TERM $MAINPID
 LimitNOFILE=100000
 [Install]
 WantedBy=multi-user.target
 #修改配置文件，设置pid文件路径
[root@ubuntu ~]# cat /apps/nginx/conf/nginx.conf
pid /apps/nginx/run/nginx.pid;

#重载服务脚本
[root@ubuntu ~]# systemctl daemon-reload 
#直接启动的 nginx 不能用 service 来管理
[root@ubuntu ~]# systemctl status nginx
```

#### 4.3.2Nginx命令与信号

```bash
#显示帮助信息
[root@ubuntu ~]# nginx -h

#检查配置文件语法，并测试配置文件
[root@ubuntu ~]# nginx -t
 nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
 nginx: configuration file /etc/nginx/nginx.conf test is successful
 
 #检查配置文件语法，并测试配置文件，仅输出错误信息
[root@ubuntu ~]# nginx -t -q
```

发送信号

```bash
#在服务端创建一个100M的文件
[root@ubuntu ~]# dd if=/dev/zero of=/var/www/html/test.img bs=1M count=100
 #客户端限速下载，每秒下1M，所以需要100M
[root@ubuntu ~]# wget --limit-rate=1024000 http://10.0.0.206/test.img

#发送quit 信号
[root@ubuntu ~]# nginx -s quit
 #还有一个 worker 进程，下载请求没有中断
[root@ubuntu ~]# ps aux | grep nginx

#但无法建立新连接
[root@ubuntu ~]# curl 127.1

#下载请求完成后，就没有进程，彻底退出
[root@ubuntu ~]# ps aux | grep nginx
```

```bash
#reload信号
```

#### 4.3.3Nginx 平滑升级和回滚

Nginx 的平滑升级是指在不中断服务的情况下进行软件版本或配置文件的更新。通过平滑升级，Nginx  能够在运行时应用新的配置或软件版本，继续处理请求，而不影响现有的连接

![image-20250311141017171](image-20250311141017171.png)

```bash
#查看当前使用的版本和编译选项
[root@ubuntu ~]# nginx -V

#修改当前配置文件，至少保证两个worker进程，便于测试
[root@ubuntu ~]# cat /apps/nginx/conf/nginx.conf
 worker_processes  2;
 [root@ubuntu ~]# nginx -s reload
 [root@ubuntu ~]# ps auxf | grep nginx
 
#编译新版本
[root@ubuntu ~]# wget https://nginx.org/download/nginx-1.24.0.tar.gz
[root@ubuntu ~]# tar xf nginx-1.24.0.tar.gz 
[root@ubuntu ~]# cd nginx-1.24.0
[root@ubuntu nginx-1.24.0]# ./configure --prefix=/apps/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre --with-stream --with-stream_ssl_module --with-stream_realip_module
 
 #只需要执行 make， 会在 objs 目录中生成新的二进制文件
[root@ubuntu nginx-1.24.0]# make

#新版二进制文件
[root@ubuntu nginx-1.24.0]# ./objs/nginx -v
 nginx version: nginx/1.24.0
 #现在正在使用的
[root@ubuntu nginx-1.24.0]# nginx -v
 nginx version: nginx/1.22.1
 
#保留旧版二进制文件备份
[root@ubuntu nginx-1.24.0]# mv /apps/nginx/sbin/nginx{,.122} 
[root@ubuntu nginx-1.24.0]# ls /apps/nginx/sbin/

#复制新的二进制文件
[root@ubuntu nginx-1.24.0]# cp objs/nginx /apps/nginx/sbin/
[root@ubuntu nginx-1.24.0]# ls /apps/nginx/sbin/

#检测，配置文件可用，版本己更新
[root@ubuntu nginx-1.24.0]# nginx -t

[root@ubuntu nginx-1.24.0]# nginx -v

#当前进程是旧版本的进程
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
#查看响应头，是旧版本的 Nginx
[root@ubuntu nginx-1.24.0]# curl 127.1 -I

#在服务端创建文件
[root@ubuntu nginx-1.24.0]# dd if=/dev/zero of=/apps/nginx/html/test.img bs=1M count=100

#向master 进程发送信号
[root@ubuntu nginx-1.24.0]# kill -USR2 6757

#生成了新的master 进程 88856，该进程下有两个 worker 进程，分别是 88857,88858
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx

#生成了新的PID文件
[root@ubuntu nginx-1.24.0]# ls -lh /apps/nginx/run/

#现在访问还是旧版本提供服务
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
```

![image-20250311141853595](image-20250311141853595.png)

```bash
#客户端限速下载
[root@ubuntu ~]# wget --limit-rate=102400 http://10.0.0.208/test.img
#服务端继续发送信号，此信号会关闭旧的 woker 进程，新请求交由新的 worker 进程处理
[root@ubuntu nginx-1.24.0]# kill -WINCH 6757

#查看进程，旧的 master 进程下还有一个 worker 进程，用于维持下载连接
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx

#新的连接己经由新版本来响应了
[root@ubuntu nginx-1.24.0]# curl 127.1 -I

#下载请求结束后，旧的 woker 进程全部退出
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx

#观察一段时间后，如果业务没有问题，则可以继续发送信号，退出旧的 master 进程，至此升级完成
[root@ubuntu nginx-1.24.0]# kill -QUIT 6757
```

回滚

```bash
#观察业务，需要回滚  
#先还原二进制文件
[root@ubuntu nginx-1.24.0]# ls -l /apps/nginx/sbin/

[root@ubuntu nginx-1.24.0]# mv /apps/nginx/sbin/nginx{,.124}        
[root@ubuntu nginx-1.24.0]# mv /apps/nginx/sbin/nginx{.122,}        
[root@ubuntu nginx-1.24.0]# ls -l /apps/nginx/sbin/

#还原回来了
[root@ubuntu nginx-1.24.0]# nginx -v

[root@ubuntu nginx-1.24.0]# nginx -t

#发送信号，拉起旧的 worker 进程
[root@ubuntu nginx-1.24.0]# kill -HUP 6757
 [root@ubuntu nginx-1.24.0]# ps auxf | grep nginx
 
#此时请求还是由新的 worker 进程响应
[root@ubuntu nginx-1.24.0]# curl 127.1 -I

#继续发送信号，优雅的退出新版的 master 进程
[root@ubuntu nginx-1.24.0]# kill -QUIT 88856

#己经还原回去了
[root@ubuntu nginx-1.24.0]# ps auxf | grep nginx

#测试
[root@ubuntu nginx-1.24.0]# curl 127.1 -I
```

#### 4.3.4**Nginx配置**

```bash
#ubuntu2204 中使用 apt 安装的 nginx 的配置文件
[root@ubuntu ~]# ls -l /etc/nginx/
```

##### 主配置文件

```bash
[root@ubuntu ~]# cat /etc/nginx/nginx.conf | grep -Ev "#|^$"
#全局配置
 user www-data; #指定worker 进程运行时的用户和组，默认值为 nobody
 worker_processes auto;  #指定启动的 worker 进程数量 auto表示有几个CPU核心就开启几个进程
 pid /run/nginx.pid;
 worker_priority N;#worker 进程优先级取值为 -20 到 19
 include /etc/nginx/modules-enabled/*.conf;#文件包含,指定要包含的文件路径及规则，可以使用通配符
 #事件驱动相关的配置
 events {
 worker_connections 768;#单个worker进程所支持的最大并发连接数
 }
 #http/https 协议相关配置段
 http {
 sendfile on;
 tcp_nopush on;
 types_hash_max_size 2048;
 include /etc/nginx/mime.types;
 default_type application/octet-stream;
 ssl_prefer_server_ciphers on;
 access_log /var/log/nginx/access.log;
 error_log /var/log/nginx/error.log;
 gzip on;
 include /etc/nginx/conf.d/*.conf;
 include /etc/nginx/sites-enabled/*;
 }
#mail 协议相关配置段， 此部份默认被注释
mail {
 ......
 ......  
server {
 ......
 ......
 }
 }
# stream 协议相关配置，默认无此部份
stream {
 ......
 ......
 }
```

https://nginx.org/en/docs/events.html        #事件驱动模型说明文档

范例：worker 进程与 cpu 核心绑定

范例：设置 worker 进程优先级

```bash
[root@ubuntu ~]# cat /etc/nginx/nginx.conf | grep worker_priority
 worker_priority -20;
```

范例：设置 worker 进程文件描述符数量

```bash
#没有设置，资源限制来自于 systemd 的默认配置
#查看systemd的默认限制
[root@ubuntu ~]# systemctl show | grep FILE
 DefaultLimitNOFILE=524288       #默认硬限制
DefaultLimitNOFILESoft=1024     #默认软限制，软限制不能超过硬限制

#在nginx 配置文件中设置
[root@ubuntu ~]# cat /etc/nginx/nginx.conf
worker_rlimit_nofile 60000;
```

##### http 配置

主配置文件中的 http 配置部份

```bash
charset utf8;
charset  charset|off;#是否在响应头 Content-Type 行中添加字符集默认值 off
sendfile on|off;#默认值 off,on表示使用 sendfile 函数来传送数据,即零拷贝
tcp_nopush on|off; #默认值 off，表示有tcp数据了立即发送，on 表示等到数据包满载了再发送
tcp_nodelay on|off; #此选项生效前提是开启了 keepalived，默认值 on 表示立即发送数据,off 表示延时

keepalive_timeout timeout [header_timeout]; #会话保持的时长，单位为秒，第二个值会出现在响应头中，可以和第一个值不一样

types_hash_max_size N; #默认值1024，用于设置 MIME 类型哈希表大小

server_tokens on|off|build|string; #默认值on，表示在响应头中显示 nginx 版本信息，off 表示不显示

include /etc/nginx/mime.types; #规定了各种后缀的文件在响应报文中的 Content-Type 对应的值
default_type application/octet-stream; #除了上述映射外，其它类型文件都用此值

server_name_in_redirect on|off; #默认值off,表示在重定向时响应头中不包含 Server 行，on 表示显示 Server 头

ssl_protocols [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3]; #当前nginx 可支持的 ssl协议版本#默认值 TLSv1 TLSv1.1 TLSv1.2 TLSv1.3

ssl_prefer_server_ciphers on|off; #默认off，表示在 SSL/TLS 握手时优先使用客户端加密套件，on表示优先使用服务端套件

access_log path[format [buffer=size] [gzip[=level]] [flush=time]
#访问日志的文件路径、格式以及其他一些选项#默认值 logs/access.log

error_log file [level];#指定错误日志路径和错误级别，默认值 error_log logs/error.log error;ebug|info|notice|warn|error|crit|alert|emerg

error_page code ... [=[response]] uri; #定义指定状态码的错误页面，可以多个状态码共用一个资源

server {
 }
```

##### 日志配置

```bash
https://nginx.org/en/docs/http/ngx_http_log_module.html #日志配置文档，可自定义日志格式
```

##### server配置

server 主要用来配置虚拟主机，可以在一台 web 服务器上支持多个域名

```bash
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/default

isten address[:port] [default_server] [ssl]; 
listen port [default_server] [ssl];
listen unix:path [default_server] [ssl];
#当前虚以主机监听的ip,port，是否是default_server，是否支持ssl 等默认值 *:80|*:8000; 可以写多条，完全说明请参考官方文档

ssl_certificate file; #当前虚拟主机证书和CA机构证书，放在一个文件中，默认值为空
ssl_certificate_key file; #私钥文件路径，默认为空

ssl_session_cache off|none|[builtin[:size]] [shared:name:size];#是否启用 ssl 缓存，默认none

ssl_session_timeout N; #客户端连接可以复用ssl session cache中缓存的有效时长，默认5m
ssl_ciphers ciphers; #指定 SSL/TLS 加密算法，默认值HIGH:!aNULL:!MD5;

ssl_prefer_server_ciphers on|off; #默认off，表示在SSL/TLS握手时优先使用客户端加密套件，on表示优先使用服务端套件

root path; #当前虚拟主机网页文件目录，写在location中，文件路径是 root+location

index file ...; #当前虚拟主机的默认页面，可以写多个，按顺序生效，默认 index.html
server_name name ...; #虚拟主机域名，可以写多个值，客户端请求头中的 Host 字段会与此处匹配

location / {
 ......
 ......
}
```

##### location配置

一个 server 配置段中可以有多个 locatio 配置，用于实现从 uri 到文件系统的路径映射;Ngnix 会根据用户请求的 uri 来检查定义的所有location，按一定的优先级找出一个最佳匹配，而后应用其配置location 指令作用于 server 配置段中，也可以嵌套

```bash
location [ = | ~ | ~* | ^~ ] uri { ... }
= #用于标准uri前，需要请求字串与uri精确匹配，区分大小写
^~ #用于标准uri前，表示包含正则表达式，匹配以特定字符串开始，区分大小写
~ #用于标准uri前，表示包含正则表达式，区分大小写
~* #用于标准uri前，表示包含正则表达式，不区分大写
/str #不带符号 匹配以 str 开头的 uri，/ 也是一个字符
\ #用于标准uri前，表示包含正则表达式并且转义字符，可以将 . * ?等转义为普通符号
@name #定义

#匹配规则优先级
=, ^~, ~/~*, /str
```

![image-20250311223128503](image-20250311223128503.png)

#### 4.3.5多虚拟主机实现

多虚拟主机是指在一台 Nginx 服务器上配置多个网站

基于IP地址实现多虚拟主机

基于端口号实现多虚拟主机

基于域名实现多虚拟主机

##### 基于域名实现多虚拟主机

在 Nginx 中配置多个 server 段，每个 server 中设置一个虚拟主机配置，客户端访问服务器时，会根据客户端请求头中的 Host 字段值来匹配 server 段中的配置，从而访问不同的网站

```bash
[root@ubuntu ~]# cd /etc/nginx/sites-enabled/
#设置两个域名配置文件
[root@ubuntu sites-enabled]# cat www.m99-magedu.com
server{
 listen 80;
 index index.html default.htm a.txt;   #默认 index.html 生效，往后优先级
 server_name www.m99-magedu.com;
 root /var/www/html/www.m99-magedu.com;
}
[root@ubuntu sites-enabled]# cat www.m99-magedu.net 
server{
 listen 80;
 server_name www.m99-magedu.net;
 root /var/www/html/www.m99-magedu.net;
}
#测试配置文件并重新加载服务
[root@ubuntu ~]# nginx -t
[root@ubuntu ~]# systemctl reload nginx.service


#修改默认页面，创建网站目录和首页
[root@ubuntu ~]# mv /var/www/html/index.nginx-debian.html /tmp/
[root@ubuntu ~]# echo "welcome to nginx" > /var/www/html/index.html
[root@ubuntu ~]# mkdir /var/www/html/www.m99-magedu.{com,net}
[root@ubuntu ~]# echo "this page from com" > /var/www/html/www.m99-
magedu.com/index.html
[root@ubuntu ~]# echo "this page from net" > /var/www/html/www.m99-
magedu.net/index.html

#测试配置文件并重新加载服务
[root@ubuntu ~]# nginx -t
[root@ubuntu ~]# systemctl reload nginx.service
#客户端配置域名解析并测试
[root@ubuntu ~]# cat /etc/hosts
10.0.0.206 www.m99-magedu.com   www.m99-magedu.net
```

默认虚拟主机配置

\#**在没有定义 default_server 的情况下，默认会被第一个配置文件命中**

![image-20250312222534476](image-20250312222534476.png)

```bash
#客户端增加 abc.m99-magedu.org def.m99-magedu.org 的解析
#但服务端没有该域名的配置
[root@ubuntu ~]# cat /etc/hosts
#测试，被服务端兜底的配置命中
[root@ubuntu ~]# curl abc.m99-magedu.org
welcome to nginx


#去掉默认配置中的 default_server
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/default
server {
 #listen 80 default_server;
 #listen [::]:80 default_server;
 
 #重载服务并测试 
[root@ubuntu ~]# systemctl reload nginx.service

[root@ubuntu ~]# curl abc.m99-magedu.org
this page from abc.m99-magedu.org
#此处被 abc 的配置命中
[root@ubuntu ~]# curl def.m99-magedu.org
this page from abc.m99-magedu.org
#IP也被 abc 配置命中
[root@ubuntu ~]# curl http://10.0.0.206
this page from abc.m99-magedu.org

#在没有定义 default_server 的情况下，默认会被第一个配置文件命中
#主配置文件中会按此顺序引用文件
[root@ubuntu ~]# ls /etc/nginx/sites-enabled/
abc.m99-magedu.org default www.m99-magedu.com www.m99-magedu.net
```

##### 基于IP地址实现多虚拟主机

```bash
#添加IP
[root@ubuntu ~]# ip a a 10.0.0.216/24 dev ens33
[root@ubuntu ~]# ip a a 10.0.0.226/24 dev ens33
[root@ubuntu ~]# ip a a 10.0.0.236/24 dev ens33
[root@ubuntu ~]# ip a s ens33
```

```bash
#恢复 default_server ，为域名绑定不同的IP 
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/abc.m99-magedu.org 
server{
 listen 10.0.0.206:80;
 listen 10.0.0.216:80;
 server_name abc.m99-magedu.org;
 root /var/www/html/abc.m99-magedu.org;
}
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/www.m99-magedu.com 
server{
 listen 10.0.0.226:80;
 server_name www.m99-magedu.com;
 root /var/www/html/www.m99-magedu.com;
}
```

##### 基于端口号实现多虚拟主机

```bash
#服务器上所有IP 的81，82端口都会被此规则匹配
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/abc.m99-magedu.org 
server{
 listen 81;
 listen 82;
 server_name abc.m99-magedu.org;
 root /var/www/html/abc.m99-magedu.org;
}
#所有88端口的访问都会被此规则匹配
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/www.m99-magedu.com
server{
 listen 88;
 server_name www.m99-magedu.com;
 root /var/www/html/www.m99-magedu.com;
}
```

#### 4.3.6location指令

root和alias

![image-20250313140815401](image-20250313140815401.png)

**location** **规则优先级**

![image-20250313140934546](image-20250313140934546.png)

##### @location 重定向

```bash
server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       
       error_page 404 @error;
       
       location @error {
       default_type text/html;
               return 200 "page not found";
       }
}
```

#### 4.3.7Nginx常用功能

##### Nginx 四层访问控制

Nginx 中的访问控制功能基于 ngx_http_access_module 模块实现，可以通过匹配客户端源 IP 地址进行限制

该模块是默认模块，在使用 apt/yum 安装的环境中默认存在，如果想要禁用，需要自行编译，然后显式声明禁用该模块

```bash
https://nginx.org/en/docs/http/ngx_http_access_module.html
```

![image-20250313163504173](image-20250313163504173.png)

##### Nginx 账户认证

Nginx 中的账户认证功能由 ngx_http_auth_basic_module 模块提供，该模块也是默认模块

此种认证方式并不安全，如果服务端是 http 协议，而非 https 协议，则用户名和密码在网络中是明文传输的，可以被抓包工具截获

![image-20250313163921507](image-20250313163921507.png)

![image-20250313163930149](image-20250313163930149.png)

```bash
# 命令行中写法
[root@ubuntu ~]# curl http://jerry:123456@www.m99-magedu.com/a.html
a.html
[root@ubuntu ~]# curl -u tom:123456 --basic http://www.m99-magedu.com/a.html
a.html
```

##### 自定义错误页面

在没有配置错误处理页面的情况下，非 200 状态码的响应请求返回的都是 Nginx 默认页面，我们可以通过指令设置自定义的错误页面，不同的虚拟主机，不同的错误都可以设置成不同的错误页面

```bash
server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
        
       error_page 400 404 502 503 504 error.html; #自定义指定状态码的错误页面
        
       location = /error.html {
               root /data/errors;
       }
}

[root@ubuntu ~]# ls /data/errors/
error.html

server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       
       error_page 400 404 =302 /index.html; #通过302 重定向到index.hmtl
}

server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       error_page 400 404 =302 http://www.baidu.com; #临时重定向
       error_page 402 503 =301 http://www.baidu.com; #永久重定向
}
```

##### 自定义错误日志

![image-20250313164439114](image-20250313164439114.png)

##### 检测资源是否存在

```bash
#默认虚拟主机中的 try_files
[root@ubuntu ~]# cat /etc/nginx/sites-enabled/default | grep try_files
 try_files $uri $uri/ =404;

server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       try_files $uri $uri.html $uri/index.html /index.html;
       location /a{
               try_files $uri $uri.html;
       }
       location /b{
               try_files $uri $uri.html =418;
       }
       error_log /var/log/nginx/www.m99-magedu.com.error.log;
}
# 测试
# http://www.m99-magedu.com/xyz 先找 xyz，往后依次是 xyz.html xyz/index.html /index.html
# http://www.m99-magedu.com/a 如果有 a 或 a.html 会匹配到，返回状态码是200，如果没有则返回 500错误页面
# http://www.m99-magedu.com/b 如果有 b 或 b.html 会匹配到，返回状态码是200，如果没有则返回 418错误页面
```

##### 长连接配置

```bash
keepalive_timeout timeout [header_timeout]; #TCP握手建立连接后，会话可以保持多长时间，
 #在此时间内，可以继续传送数据，而不用再次握手
 #默认值 keepalive_timeout 75s
 #header_timeout 用作响应头中显示，可以与前一个值不一样
                                                #作用域 http, server, location
                                                
keepalive_requests number; #一次请求不断开连接的情况下最多可以传送多少个资源
 #默认值 keepalive_requests 1000;
 #作用域 http, server, location
 
 #在请求过程中以上两项达到一项阀值，连接就会断开
```

**作为下载服务器配置**

Nginx 的 ngx_http_autoindex_module 模块可以将目录内容按指定格式生成目录内容列表，常用作配置下载服务器

```bash
autoindex on|off; #是否显示目录内容列表,默认 off
autoindex_exact_size on|off; #是否以友好的方式显示文件大小，默认 on，表示显示文件具体字节数
autoindex_format html|xml|json|jsonp; #数据显示格式，默认 html
autoindex_localtime on|off #是否以本地时区显示文件时间属性，默认off，以UTC时区显示
#以上指令作用域均为 http, server, location
```

![image-20250313165946277](image-20250313165946277.png)

![image-20250313170007119](image-20250313170007119.png)

![image-20250313170028648](image-20250313170028648.png)

##### 作为上传服务器配置

```bash
client_max_body_size size; #设置允许客户端上传单个文件最大值，超过此值会响应403，默认1m
client_body_buffer_size size #用于接收每个客户端请求报文的body部分的缓冲区大小，默认16k，超过此大小时，
#数据将被缓存到由 client_body_temp_path 指令所指定的位置
 
client_body_temp_path path [level1 [level2 [level3]]]; 
#设定存储客户端请求报文的body部分的临时存储路径及子目录结构和数量
#子目录最多可以设三级，数字表示当前级别创建几个子目录，16进制
```

![image-20250313170248328](image-20250313170248328.png)

##### 限流限速（流量控制）

**限流限速背景**

限速（rate limiting）是 Nginx 中一个非常有用但是经常被误解且误用的功能特性。我们可以用它来限制在一段时间内的 HTTP 请求的数量，这些请求可以是如 GET 这样的简单请求又或者是用来填充登录表单的 POST 请求

限速还可以用于安全防护用途，例如限制密码撞库暴力破解等操作的频率，也可以通过把请求频率限制在一个正常范围来抵御 DDoS 攻击，更常见的使用情况是通过限制请求的数量来确保后端的 upstream 服务器不会在短时间内遭受到大量的流量访问从而导致服务异

目前 Nginx 中主要的三种限速操作分别是：限制请求数（request），限制连接数（connection），限制响应速度（rate），对应在 Nginx 中的模块指令分别是 limit_req，limit_conn 和 limit_rate 三部份

**限制单一连接下载速度**

```bash
limit_rate rate; #对单个客户端连接限速，默认单位为字节，其它单位需要显式指定，表示每秒的下载速度
#限速只对单一连接而言，同一客户端两个连接，总速率为限速2倍，默认值0，表示不限制

limit_rate_after size; #在传输了多少数据之后开始限速，默认值0，表示一开始就限速
#作用域 http, server, location, if in location
```

![image-20250313172147066](image-20250313172147066.png)

**限制客户端请求数**

https://nginx.org/en/docs/http/ngx_http_limit_req_module.html

![image-20250313172605826](image-20250313172605826.png)

**限制客户端并发连接数**

https://nginx.org/en/docs/http/ngx_http_limit_conn_module.html

![image-20250313172902759](image-20250313172902759.png)

##### Nginx 状态页

https://nginx.org/en/docs/http/ngx_http_stub_status_module.html

```bash
stub_status; #添加此指令后可开启 Nginx 状态页，作用域 server, location
```

```bash
server{
       listen 80;
       server_name www.m99-magedu.com;
       root /var/www/html/www.m99-magedu.com;
       location /status{
                     stub_status;
       }
}

#在浏览器中访问 http://www.m99-magedu.com
Active connections: 2
server accepts handled requests 
8 8 55
Reading: 0 Writing: 1 Waiting: 1
```

##### Nginx第三方模块的使用

https://github.com/vozlt/nginx-module-vts # 第三方流量监控模块

https://github.com/openresty/echo-nginx-module # echo 模块，可以直接输出

##### Nginx中的变量

Nginx 变量可以在配置文件中使用，用作判断或定义日志格式等场景，Nginx 变量可以分为内置变量和自定义变量两种

**Nginx** **内置变量**

Nginx 内置变量是 Nginx 自行定义的，可以直接调用

https://nginx.org/en/docs/varindex.html

![image-20250313181048277](image-20250313181048277.png)

![image-20250313181105325](image-20250313181105325.png)

**用户自定义变量**

```bash
set $variable value;
```

##### 自定义访问日志

```bash
#二进制包安装的nginx 默认 access_log 配置
[root@ubuntu ~]# cat /etc/nginx/nginx.conf | grep access_log
 access_log /var/log/nginx/access.log;
#默认 log_format 内容
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

```bash
#定义日志格式常用的变量
$remote_addr #客户端的IP地址
$remote_user #使用 HTTP 基本身份验证时的远程用户
$time_local #服务器本地时间
$request #客户端请求的 HTTP 方法、URI 和协议
$status #服务器响应的状态码
$body_bytes_sent #发送给客户端的字节数，不包括响应头的大小
$http_referer #客户端跳转前的来源页面
$http_user_agent #客户端的用户代理字符串
$http_x_forwarded_for #通过代理服务器传递的客户端真实 IP 地址
$host #请求的主机头字段
$server_name #服务器名称
$request_time #请求处理时间
$upstream_response_time #从上游服务器接收响应的时间
$upstream_status #上游服务器的响应状态码
$time_iso8601 #ISO 8601 格式的本地时间
$request_id #用于唯一标识请求的 ID
$ssl_protocol #使用的 SSL 协议
$ssl_cipher #使用的 SSL 加密算法
```

![image-20250313181417789](image-20250313181417789.png)

##### Nginx 压缩功能

##### favicon 图标配置

favicon.ico 文件是浏览器收藏网址时显示的图标，当客户端使用浏览器问页面时，浏览器会自己主动发起请求获取页面的 favicon.ico文件，但是当浏览器请求的favicon.ico文件不存在时，服务器会记录404 日志，而且浏览器也会显示404报错

##### Nginx 实现 Https

Nginx 中的 Https 功能需要 ngx_http_ssl_module 模块支持，使用 Yum/apt 安装的 Nginx 中己经包含了该模块的功能，如果使用的是自行通过源码编译安装的 Nginx，需要在编译的时候指定相关编译项

https://nginx.org/en/docs/http/ngx_http_ssl_module.html

```bash
#安装软件
[root@ubuntu ~]# apt install easy-rsa -y
[root@ubuntu ~]# cd /usr/share/easy-rsa/
#初始化证书目录
[root@ubuntu easy-rsa]# ./easyrsa init-pki
init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /usr/share/easy-rsa/pki

[root@ubuntu easy-rsa]# tree pki/
#生成CA机构证书，不使用密码
[root@ubuntu easy-rsa]# ./easyrsa build-ca nopass

#生成私钥和证书申请文件
[root@ubuntu easy-rsa]# ./easyrsa gen-req www.m99-magedu.com nopass
#签发证书
[root@ubuntu easy-rsa]# ./easyrsa sign-req server www.m99-magedu.com

#合并服务器证书，签发机构证书为一个文件，注意顺序
[root@ubuntu easy-rsa]# cat pki/issued/www.m99-magedu.com.crt pki/ca.crt > 
pki/www.m99-magedu.com.pem
#给私钥加读权限
[root@ubuntu easy-rsa]# chmod +r pki/private/www.m99-magedu.com.key
#查看
[root@ubuntu easy-rsa]# tree pki
```

```bash
#配置https
#http 和 https 也可以写在同一个配置中
server{
 listen 80;
 server_name www.m99-magedu.com;
 root /var/www/html/www.m99-magedu.com;
}
server{
 listen 443 ssl;
 server_name www.m99-magedu.com;
 root /var/www/html/www.m99-magedu.com;
 ssl_certificate /usr/share/easy-rsa/pki/www.m99-magedu.com.pem;
 ssl_certificate_key /usr/share/easy-rsa/pki/private/www.m99-magedu.com.key;
 ssl_session_cache shared:sslcache:20m;
 ssl_session_timeout 10m;
}
#在浏览器中测试，如果浏览器提示不安全，则导入CA证书后再次重启浏览器

#配置http 强制跳转 https
server{
       listen 80;
       server_name www.m99-magedu.com;
       return 301 https://$host$request_uri; #301重定向
       rewrite ^(.*) https://$server_name$1 permanent; #rewrite 重定向，二选一
}
```

![image-20250313191848315](image-20250313191848315.png)

##### Nginx 中配置防盗链

盗链是指某站点未经允许引用其它站点上的资源，

基于访问安全考虑，Nginx 支持通过 ngx_http_referer_module 模块，检查和过滤 Referer 字段的值，来达到防盗链的效果

##### Nginx 中的 Rewrite

在 Nginx 中，rewrite 指令用于重写 URI，允许 Nginx 修改客户端请求的 URI，基于此，可用该指令实现 URL 重定向，修改请求参数，改变请求含义，改变 URL 结构等，该指令来自于ngx_http_rewrite_module 模块

```bash
https://nginx.org/en/docs/http/ngx_http_rewrite_module.html
```

break：终止当前代码段中的所有 rewrite 匹配

last：中止当前 location 中的 rewrite 匹配，用替换后的 RUI 继续从第一条规则开始执行下一轮rewrite

##### 指令语法

```bash
if set return 等等

location = /return_url{

        return http://www.baidu.com;

}

location /{
               rewrite /1.html /2.html permanent;
               rewrite /2.html /3.html;
}
```

#### 4.3.8Nginx 反向代理

**正向代理（Forward Proxy）**

**特点**

代理服务器位于客户端和目标服务器之间

客户端向代理服务器发送请求，代理服务器将请求发送到目标服务器，并将目标服务器的响应返回给客户端

目标服务器不知道客户端的存在，它只知道有一个代理服务器向其发送请求

客户端通过正向代理访问互联网资源时，通常需要配置客户端来使用代理

**用途**

突破访问限制：用于绕过网络访问限制，访问受限制的资源

隐藏客户端身份：客户端可以通过正向代理隐藏其真实 IP 地址

**反向代理（Reverse Proxy）**（比如Nginx，CDN）

特点

代理服务器位于目标服务器和客户端之间

客户端向代理服务器发送请求，代理服务器将请求转发给一个或多个目标服务器，并将其中一个目标服务器的响应返回给客户端

目标服务器不知道最终客户端的身份，只知道有一个代理服务器向其发送请求

用于将客户端的请求分发给多个服务器，实现负载均衡

**用途**

负载均衡：通过将流量分发到多个服务器，确保服务器的负载均匀分布

缓存和加速：反向代理可以缓存静态内容，减轻目标服务器的负载，并提高访问速度

安全性：隐藏真实服务器的信息，提高安全性，同时可以进行 SSL 终止（SSL Termination）

**不同点**

方向：**正向代理代理客户端，反向代理代理服务器**

目的：正向代理主要用于访问控制和隐藏客户端身份，反向代理主要用于负载均衡、缓存和提高安全性

配置：客户端需要配置使用正向代理，而反向代理是对服务器透明的，客户端无需感知

![image-20250313223604985](image-20250313223604985.png)

##### Nginx 和 LVS

Nginx 和 LVS（Linux Virtual Server） 都是流行的代理和负载均衡解决方案，但它们有一些不同的特点和应用场景

选择使用 Nginx 还是 LVS 取决于具体的应用需求和复杂度。Nginx 更适合作为 Web 服务器和应用层负载均衡器，而 LVS 更适用于传输层负载均衡

**相同点**

负载均衡：Nginx 和 LVS 都可以作为负载均衡器，将流量分发到多个后端服务器，提高系统的可用性和性能。

性能：Nginx 和 LVS 都具有高性能的特点，能够处理大量并发连接和请求

**不同点**

层次：Nginx 在应用层进行负载均衡和反向代理，而 LVS 在传输层进行负载均衡

功能：Nginx 除了负载均衡外，还可以作为反向代理和静态文件服务器；而 LVS 主要专注于负载均衡，实现简单而高效的四层分发

配置和管理：Nginx 配置相对简单，易于管理，适用于各种规模的应用；LVS 需要深入了解 Linux 内核和相关配置，适用于大规模和对性能有更高要求的场景





LVS 不监听端口，不处理请求数据，不参与握手流程，只会在内核层转发数据报文

Nginx 需要在应用层接收请求，根据客户端的请求参数和Nginx中配置的规则，再重新作为客户端向后端服务器发起请求

![image-20250313224153173](image-20250313224153173.png)

##### 实现 http 协议反向代理

Nginx 可以基于ngx_http_proxy_module 模块提供 http 协议的反向代理服务，该模块是 Nginx 的默认模块

http://nginx.org/en/docs/http/ngx_http_proxy_module.html

**基本配置**

```bash
#转发到指定IP
server{
 listen 80;
 server_name www.m99-magedu.com;
 #root /var/www/html/www.m99-magedu.com;
 location /{
 proxy_pass http://10.0.0.210; #210要开启WEB服务，请求的是默认default_Serve 配置
 }
}
```

##### 动静分离

##### 代理服务器实现数据缓存

前置条件：各服务器时间和时区先统一，方便测试

```bash
#Proxy Server 配置
#定义缓存
proxy_cache_path /tmp/proxycache levels=1:2 keys_zone=proxycache:20m 
inactive=60s max_size=1g;
server{
 listen 80;
 server_name www.m99-magedu.com;
 location /static{
 proxy_pass http://10.0.0.210;
 proxy_set_header Host "static.m99-magedu.com";
 proxy_cache proxycache; #使用缓存
 proxy_cache_key $request_uri;
 proxy_cache_valid 200 302 301 90s;
 proxy_cache_valid any 2m; #此处一定要写，否则缓存不生效
 
 }
}

#重载，生成缓存目录
[root@ubuntu ~]# nginx -s reload
[root@ubuntu ~]# ll /tmp/proxycache/
```

##### 实现客户端IP地址透传

在使用Nginx 做代理的情况下，默认后端服务器无法获取客户端真实IP地址

修改代理服务器配置，透传真实客户端IP

```bash
server{
       listen 80;
       server_name www.m99-magedu.com;
        #root /var/www/html/www.m99-magedu.com;
       location /{
               proxy_pass http://10.0.0.210;
               proxy_set_header X-Real-IP $remote_addr;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       }
}
#表示将客户端IP追加请求报文中X-Forwarded-For首部字段,多个IP之间用逗号分隔,如果请求中没有X-Forwarded-For,就使用$remote_addr
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#客户端测试 $remote_addr 获取代理IP，$http_x_real_ip 获取真实客户端IP，$http_x_forwarded_for 获取真实客户端IP
```

##### 多级代理服务器IP地址透传

##### 实现 http 协议反向代理的负载均衡

在实现 Nginx 反向代理的基础上，可以基于 ngx_http_upstream_module 模块实现后端服务器的分组，权重分配，状态监测，调度算法等高级功能

https://nginx.org/en/docs/http/ngx_http_upstream_module.html



ip_hash 算法只使用 IPV4 的前 24 位做 hash 运算，如果客户端IP前24位一致，则会被调度到同一台后端服务器



```bash
upstream group1{
#ip_hash;
#hash $remote_addr;三台 server 权重一样，调度算法 hash($remoute_addr)%3
#least_conn;  Proxy Server 配置，最少连接调度算法

#两个 server 被调度的比例为 3:1
 server 10.0.0.210 weight=3;
 server 10.0.0.159;
 #设置 backup，当 10.0.0.210 和 10.0.0.159 都不可用时，请求会被调度到 10.0.0.213
 server 10.0.0.213 backup;
}

upstream group2{
#10.0.0.210 同时只能维持两个活动连接
 server 10.0.0.110:8080 max_conns=2;
 server 10.0.0.120:8080;
}
```

![image-20250313233340274](image-20250313233340274.png)

#### 4.3.9综合案例

实现 http 自动重定向至 https，并将客户端 https 请求通过负载均衡的方式反向代理到后端的多台 http 服务器上

![image-20250313233942369](image-20250313233942369.png)

```bash
# upstream 配置
upstream group1{
 server 10.0.0.210;
 server 10.0.0.159;
}

# http 重定向到 https
server{
 listen 80;
 server_name www.m99-magedu.com;
 return 302 https://$server_name$request_uri;
}

# https 配置
server{
 listen 443 ssl http2;
 server_name www.m99-magedu.com;
 ssl_certificate /usr/share/easy-rsa/pki/www.m99-magedu.com.pem;
 ssl_certificate_key /usr/share/easy-rsa/pki/private/www.m99-magedu.com.key;
 ssl_session_cache shared:sslcache:20m;
 ssl_session_timeout 10m;
 
 location /{
   proxy_pass http://group1;
   proxy_set_header host $http_host;
 }
}
```

#### 4.3.10Nginx 的四层代理和负载

http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html # 非http协议的反向代理

https://nginx.org/en/docs/stream/ngx_stream_upstream_module.html # 非http协议的负载均衡

**实现TCP协议的反向代理**

真正操作还得看文档，因为每个软件他的配置可以会阻断监听

```bash
stream{
 server{
 listen 3306;
 proxy_pass 10.0.0.210:3306;
 } 
 
 server{
 listen 6379;
 proxy_pass 10.0.0.159:6379;
 }
}
```

**实现TCP协议的负载均衡**

```bash
stream{
 upstream mysql{
 server 10.0.0.210:3306;
 server 10.0.0.159:3306;
 }
 
 upstream redis{
 server 10.0.0.210:6379;
 server 10.0.0.159:6379;
 }
 
 server{
 listen 3306;
 proxy_pass mysql;
 }
 
 server{
 listen 6379;
 proxy_pass redis;
 }
}
```

#### 4.3.11实现 FastCGI 代理

关于 PHP 和 FastCGI 的内容请回顾 Apache 章节内容，此章节重点讲解 Nginx 将前端请求通过 FastCGI 协议反向代理到后端的 PHP-FPM，将请求交由 PHP 程序处理

### 4.4Nginx二次开发版

#### Tengine

Tengine是一个基于Nginx的开源Web服务器和反向代理服务器，旨在提供高性能和高并发处理能力。

性能优化：Tengine在Nginx的基础上进行了一系列性能优化，特别是针对高并发场景。这包括对连接处理、负载均衡、静态文件服务等方面的优化；

动态模块加载：Tengine支持动态模块加载，这使得用户可以根据具体需求在运行时加载或卸载模块，而无需重新编译和部署整个服务器；

WebSocket支持：Tengine内置对WebSocket协议的支持，使其适用于实时通信应用，如即时聊天、实时通知等；

社区支持：Tengine在开源社区中有一定的用户群体，用户可以通过社区渠道获取支持和反馈

```bash
https://tengine.taobao.org/ #官网
https://tengine.taobao.org/documentation.html #文档
https://tengine.taobao.org/download/nginx@taobao.pdf #淘宝网Nginx定制开
发实战
https://tengine.taobao.org/download/taobao_nginx_2012_06.pdf #淘宝网Nginx应用、定制开发实战
```

#### openresty

![image-20250314143607921](image-20250314143607921.png)

```bash
https://openresty.org/cn/ #官网
```

## 5.web应用服务器TOMCAT

### 5.1web技术

#### 前端三大核心技术

HTML（HyperText Markup Language）超文本标记语言，它不同于一般的编程语言。超文本即超出纯 文本的范畴，例如：描述文本颜色、大小、字体等信息，或使用图片、音频、视频等非文本内容。

CSS（Cascading Style Sheets）层叠样式表

Javascript 简称JS，是一种动态的弱类型脚本解释性语言，和HTML、CSS并称三大WEB核心技术，得到 了几乎主流浏览器支持。

**同步** 

交互式网页，用户提交了请求，就是想看到查询的结果。服务器响应到来后是一个全新的页面内容，哪 怕URL不变，整个网页都需要重新渲染。例如，用户填写注册信息，只是2次密码不一致，提交后，整个 注册页面重新刷新，所有填写项目重新填写(当然有办法让用户减少重填)。这种交互非常不友好。从代价 的角度看，就是为了注册的一点点信息，结果返回了整个网页内容，不但浪费了网络带宽，还需要浏览 器重新渲染网页，太浪费资源了，影响了用户体验和感受。上面这些请求的过程，就是同步过程，用户 发起请求，页面整个刷新，直到服务器端响应的数据到来并重新渲染。

**异步**

Ajax 即"Asynchronous Javascript And XML"（异步 JavaScript 和 XML），是指一种 创建交互式、快速动态网页应用的网页开发技术，最早起源于1998年微软的Outlook Web Access开发 团队。Ajax 通过在后台与服务器进行少量数据交换， 可以使网页实现异步更新。这意味着可以在不重新 加载整个网页的情况下，对网页的某部分进行更新。Javascript 通过调用浏览器内置的WEB API中的 XMLHttpRequest 对象实现Ajax 技术。早期Ajax结合数据格式XML，目前更多的使用JSON。利用AJAX 可实现前后端开发的彻底分离，改变了传统的开发模式。

AJAX是一种技术的组合，技术的重新发现，而不是发明，但是它深远的影响了整个WEB开发。

### 5.2Java 基础

#### 5.2.1WEB架构

**Web资源和访问**

![image-20250428001111175](image-20250428001111175.png)

PC 端或移动端浏览器访问 从静态服务器请求HTML、CSS、JS等文件发送到浏览器端，浏览器端接收后渲染在浏览器上  从图片服务器请求图片资源显示 从业务服务器访问动态内容，动态内容是请求后有后台服务访问数据库后得到的，最终返回到浏览器端

手机 App 访问 内置了HTML和JS文件，不需要从静态WEB服务器下载 JS 或 HTML。为的就是减少文件的发送，现代前 端开发使用的JS文件太多或太大了  有必要就从图片服务器请求图片，从业务服务器请求动态数据



**后台应用架构**

单体架构

微服务

微服务架构（分布式系统），各个模块/服务，各自独立出来，"让专业的人干专业的事"，独立部 署。分布式系统中，不同的服务可以使用各自独立的数据库。 服务之间采用轻量级的通信机制（通常是基于HTTP的RESTful API）

#### 5.2.2安装 openjdk

```bash
[root@centos8 ~]#dnf list "*jdk*"
[root@centos8 ~]#dnf -y install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel

[root@centos8 ~]#java -version
[root@centos8 ~]#which java
```

```bash
#一键安装二进制的JDK
[root@ubuntu1804 ~]#cat install_jdk.sh
 #!/bin/bash
 DIR=`pwd`
 JDK_FILE="jdk-8u281-linux-x64.tar.gz"
 JDK_DIR="/usr/local"
 color () {
 RES_COL=60
 MOVE_TO_COL="echo -en \\033[${RES_COL}G"
 SETCOLOR_SUCCESS="echo -en \\033[1;32m"
 SETCOLOR_FAILURE="echo -en \\033[1;31m"
 SETCOLOR_WARNING="echo -en \\033[1;33m"
 SETCOLOR_NORMAL="echo -en \E[0m"
 echo -n "$2" && $MOVE_TO_COL
 echo -n "["
 if [ $1 = "success" -o $1 = "0" ] ;then
 ${SETCOLOR_SUCCESS}
 echo -n $"  OK  "    
elif [ $1 = "failure" -o $1 = "1"  ] ;then
 ${SETCOLOR_FAILURE}
 echo -n $"FAILED"
 else
 ${SETCOLOR_WARNING}
 echo -n $"WARNING"
 fi
 ${SETCOLOR_NORMAL}
 echo -n "]"
 echo                                                                         
}
install_jdk(){
 if  [ ! -f "$DIR/$JDK_FILE" ];then
 color 1  "$JDK_FILE 文件不存在" 
exit; 
elif [ -d $JDK_DIR/jdk ];then
        color 1  
"JDK 已经安装" 
exit
 else 
        [ -d "$JDK_DIR" ] || mkdir -pv $JDK_DIR
 fi
 tar xvf $DIR/$JDK_FILE  -C $JDK_DIR
 cd  $JDK_DIR && ln -s jdk* jdk 
cat >  /etc/profile.d/jdk.sh <<EOF
 export JAVA_HOME=$JDK_DIR/jdk
 export PATH=\$PATH:\$JAVA_HOME/bin
 #export JRE_HOME=\$JAVA_HOME/jre
 #export CLASSPATH=.:\$JAVA_HOME/lib/:\$JRE_HOME/lib/
 EOF
 .  /etc/profile.d/jdk.sh
 java -version && color 0  "JDK 安装完成" || { color 1  "JDK 安装失败" ; exit; }
 }
install_jdk
```

### 5.3tomcat基础功能

#### 5.3.1tomcat安装

```bash
[root@rocky8 ~]#yum list |grep tomcat
[root@rocky8 ~]#yum -y install tomcat tomcat-admin-webapps tomcat-docs-webapp tomcat-webapps
[root@rocky8 ~]#systemctl enable --now tomcat.service

[root@centos7 ~]#ss -ntl

[root@centos7 ~]#getent passwd tomcat
[root@centos7 ~]#ps aux|grep tomcat
```

**Ubuntu 包安装 tomcat**

```bash
[root@ubuntu2204 ~]#apt list |grep tomcat
[root@ubuntu2204 ~]#apt  update;apt -y install tomcat9 tomcat9-admin tomcat9-docs tomcat9-examples
[root@ubuntu2204 ~]#ss -ntl

[root@ubuntu1804 ~]#apt  update
[root@ubuntu1804 ~]#apt -y install tomcat8 tomcat8-admin tomcat8-docs
```

**二进制安装 Tomcat**

**配置 tomcat 自启动的 service 文件**

```bash
#创建tomcat专用帐户
[root@centos8 ~]#useradd -r -s /sbin/nologin tomcat
 #准备service文件中相关环境文件
[root@centos8 ~]#vim /usr/local/tomcat/conf/tomcat.conf
 [root@centos8 ~]#cat /usr/local/tomcat/conf/tomcat.conf
 #两个变量至少设置一项才能启动 tomcat
 JAVA_HOME=/usr/local/jdk
 #JRE_HOME=/usr/local/jdk/jre 
[root@centos8 ~]#chown -R tomcat.tomcat /usr/local/tomcat/
#创建tomcat.service文件
[root@centos8 ~]#vim /lib/systemd/system/tomcat.service
 [root@centos8 ~]#cat /lib/systemd/system/tomcat.service 
[Unit]
 Description=Tomcat
 #After=syslog.target network.target remote-fs.target nss-lookup.target
 After=syslog.target network.target 
 [Service]
 Type=forking
 #以下二选一
EnvironmentFile=/usr/local/tomcat/conf/tomcat.conf
 #或者，如果没有创建上面的/usr/local/tomcat/conf/tomcat.conf文件，可以加下面一行也可
Environment=JAVA_HOME=/usr/local/jdk
 ExecStart=/usr/local/tomcat/bin/startup.sh
 ExecStop=/usr/local/tomcat/bin/shutdown.sh
 PrivateTmp=true
 User=tomcat
 Group=tomcat
 [Install]
 WantedBy=multi-user.target
 
 [root@centos8 ~]#systemctl daemon-reload
 [root@centos8 ~]#systemctl enable --now tomcat
[root@centos8 ~]#systemctl status tomcat

 #查看日志
[root@centos8 ~]#tail  /var/log/messages
```

**一键安装 tomcat 脚本**

```bash
#!/bin/bash
TOMCAT_VERSION=9.0.69
JDK_VERSION=8u351
TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
 #TOMCAT_FILE="apache-tomcat-9.0.69.tar.gz"
 #TOMCAT_FILE="apache-tomcat-9.0.64.tar.gz"
 #TOMCAT_FILE="apache-tomcat-9.0.59.tar.gz"
 #TOMCAT_FILE="apache-tomcat-8.5.64.tar.gz"
JDK_FILE="jdk-${JDK_VERSION}-linux-x64.tar.gz"
 #JDK_FILE="jdk-8u351-linux-x64.tar.gz"
 #JDK_FILE="jdk-8u333-linux-x64.tar.gz"
 #JDK_FILE="jdk-8u281-linux-x64.tar.gz"
 #JDK_FILE="jdk-11.0.14_linux-x64_bin.tar.gz"
JDK_DIR="/usr/local"
 TOMCAT_DIR="/usr/local"
 DIR=`pwd`
 
 color () {
 RES_COL=60
 MOVE_TO_COL="echo -en \\033[${RES_COL}G"
 SETCOLOR_SUCCESS="echo -en \\033[1;32m"
 SETCOLOR_FAILURE="echo -en \\033[1;31m"
 SETCOLOR_WARNING="echo -en \\033[1;33m"
 SETCOLOR_NORMAL="echo -en \E[0m"
 echo -n "$2" && $MOVE_TO_COL
 echo -n "["
 if [ $1 = "success" -o $1 = "0" ] ;then
 ${SETCOLOR_SUCCESS}
 echo -n $"  OK  "    
elif [ $1 = "failure" -o $1 = "1"  ] ;then
 ${SETCOLOR_FAILURE}
 echo -n $"FAILED"
 else
 ${SETCOLOR_WARNING}
 echo -n $"WARNING"
 fi
 ${SETCOLOR_NORMAL}
 echo -n "]"
 echo                                                                         
}


install_jdk(){
 if  [ ! -f "$DIR/$JDK_FILE" ];then
    color 1 "$JDK_FILE 文件不存在" 
exit; 
elif [ -d $JDK_DIR/jdk ];then
    color 1  
"JDK 已经安装" 
exit
 else 
    [ -d "$JDK_DIR" ] || mkdir -pv $JDK_DIR
 fi
 tar xvf $DIR/$JDK_FILE  -C $JDK_DIR
 cd  $JDK_DIR && ln -s jdk* jdk 
cat >  /etc/profile.d/jdk.sh <<EOF
 export JAVA_HOME=$JDK_DIR/jdk
 export PATH=\$PATH:\$JAVA_HOME/bin
 #export JRE_HOME=\$JAVA_HOME/jre
 #export CLASSPATH=.:\$JAVA_HOME/lib/:\$JRE_HOME/lib/
 EOF
 .  /etc/profile.d/jdk.sh
 java -version && color 0 "JDK 安装完成" || { color 1  "JDK 安装失败" ; exit; }
 }
 install_tomcat(){
 if ! [ -f "$DIR/$TOMCAT_FILE" ];then
    color 1 "$TOMCAT_FILE 文件不存在" 
exit; 
elif [ -d $TOMCAT_DIR/tomcat ];then
    color 1 "TOMCAT 已经安装" 
exit
 else 
    [ -d "$TOMCAT_DIR" ] || mkdir -pv $TOMCAT_DIR
 fi
 tar xf $DIR/$TOMCAT_FILE -C $TOMCAT_DIR
 cd  $TOMCAT_DIR && ln -s apache-tomcat-*/  tomcat
 echo "PATH=$TOMCAT_DIR/tomcat/bin:"'$PATH' > /etc/profile.d/tomcat.sh
 id tomcat &> /dev/null || useradd -r -s /sbin/nologin tomcat
 cat > $TOMCAT_DIR/tomcat/conf/tomcat.conf <<EOF
 JAVA_HOME=$JDK_DIR/jdk
 EOF
 chown -R tomcat.tomcat $TOMCAT_DIR/tomcat/
 cat > /lib/systemd/system/tomcat.service  <<EOF
 [Unit]
 Description=Tomcat
 #After=syslog.target network.target remote-fs.target nss-lookup.target
 After=syslog.target network.target 
[Service]
 Type=forking
 EnvironmentFile=$TOMCAT_DIR/tomcat/conf/tomcat.conf
 ExecStart=$TOMCAT_DIR/tomcat/bin/startup.sh
ExecStop=$TOMCAT_DIR/tomcat/bin/shutdown.sh
 RestartSec=3
 PrivateTmp=true
 User=tomcat
 Group=tomcat
 [Install]
 WantedBy=multi-user.target
 EOF
 systemctl daemon-reload
 systemctl enable --now tomcat.service &> /dev/null
 systemctl is-active tomcat.service &> /dev/null &&  color 0 "TOMCAT 安装完成" || { 
color 1 "TOMCAT 安装失败" ; exit; }
 }
install_jdk 
install_tomcat
```

#### 5.3.2Tomcat 的文件结构和组成

![image-20250428143139498](image-20250428143139498.png)

**配置文件**

![image-20250428143315439](image-20250428143315439.png)

```bash
 #查看访问日志
[root@centos8 ~]#tail /usr/local/tomcat/logs/localhost_access_log.2020-07-14.txt
10.0.0.1 - - [14/Jul/2020:09:08:46 +0800] "GET / HTTP/1.1" 200 11215
10.0.0.1 - - [14/Jul/2020:09:08:46 +0800] "GET /tomcat.css HTTP/1.1" 200 5581
10.0.0.1 - - [14/Jul/2020:09:08:46 +0800] "GET /tomcat.png HTTP/1.1" 200 5103

#tomcat日志实现json格式的访问日志
[root@centos8 ~]#vim /usr/local/tomcat/conf/server.xml
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
 prefix="localhost_access_log" suffix=".txt"
 ########################添加下面一行,注意是一行,不要换行
#####################################
 pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;ClientUser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;AccessTime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;SendBytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;AgentVersion&quot;:&quot;%{User-Agent}i&quot;}"/>
 ################################################################################
 ########
<!-- pattern="%h %l %u %t &quot;%r&quot; %s %b" /> -->
      </Host>
    </Engine>
  </Service>
 </Server>
 [root@centos8 ~]#systemctl restart tomcat
 
  #安装json工具jq
 [root@rocky8 ~]#yum -y install jq
 
  #利用jq解析json格式
[root@rocky8 ~]#echo '{"clientip":"10.0.0.1",....|jq
```

#### 5.3.3组件

**组件分层和分类**

顶级组件 Server，代表整个Tomcat容器，一台主机可以启动多tomcat实例，需要确保端口不要产生冲突

服务类组件 Service，实现组织Engine和Connector，建立两者之间关联关系, service 里面只能包含一个Engine

连接器组件 Connector，有HTTP（默认端口8080/tcp）、HTTPS（默认端口8443/tcp）、AJP（默认端口 8009/tcp）协议的连接器，AJP（Apache Jserv protocol）是一种基于TCP的二进制通讯协议。

容器类 Engine、Host（虚拟主机）、Context(上下文件,解决路径映射)都是容器类组件，可以嵌入其它组件， 内部配置如何运行应用程序。

内嵌类 可以内嵌到其他组件内，valve、logger、realm、loader、manager等。以logger举例，在不同容器组 件内分别定义。

集群类组件 listener、cluster

**Tomcat 内部组成**

![image-20250428185052341](image-20250428185052341.png)

#### 5.3.4Java 应用部署

Tomcat中默认网站根目录是$CATALINA_BASE/webapps/ 在Tomcat的webapps目录中，有个非常特殊的目录ROOT，它就是网站默认根目录。

$CATALINA_BASE/webapps下面的每个目录都对应一个Web应用,即WebApp



每一个虚拟主机都可以使用appBase指令配置自己的站点目录，使用appBase目录下的ROOT目录作为 主站目录。

```bash
[root@centos8 ~]#cat /usr/local/tomcat/webapps/ROOT/index.html
<h1>马哥教育</h1>
[root@centos8 ~]#curl 10.0.0.8:8080/index.html  -I
HTTP/1.1 200 
Accept-Ranges: bytes
ETag: W/"22-1594212097000"

Last-Modified: Wed, 08 Jul 2020 12:41:37 GMT
Content-Type: text/html  #tomcat无指定编码,浏览器自动识别为GBK,可能会导致乱码
Content-Length: 22
Date: Wed, 08 Jul 2020 13:06:03 GMT
#httpd服务器默认指定编码为UTF-8,因为服务器本身不会出现乱码
#nginx服务器默认在响应头部没有批定编码,也会出现乱码
[root@centos8 ~]#curl 10.0.0.18/index.html  -I
HTTP/1.1 200 OK
Date: Wed, 08 Jul 2020 13:07:57 GMT
Server: Apache/2.4.37 (centos)
Last-Modified: Wed, 08 Jul 2020 12:59:55 GMT
ETag: "16-5a9edaf39d274"
Accept-Ranges: bytes
Content-Length: 22
Content-Type: text/html; charset=UTF-8
#浏览器的设置默认不是UTF-8,可能会导致乱码
```

##### 5.3.4.1主页设置

**全局配置实现修改默认主页文件**

默认情况下 tomcat 会在$CATALINA_BASE/webapps/ROOT/目录下按以下次序查找文件,找到第一个则 进行显示 

index.html index.htm index.jsp

可以通过修改 $CATALINA_BASE/conf/web.xml 中的下面

```bash
<welcome-file-list>
 [root@centos8 tomcat]#vim conf/web.xml
```

  内容修改默认页

**WebApp的专用配置文件**

将上面主配置文件conf/web.xml中的 标签 内容，复制到/usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml中

针对主站点根目录设置专用配置文件

```bash
[root@centos8 tomcat]#vim webapps/ROOT/WEB-INF/web.xml 
[root@centos8 tomcat]#cat webapps/ROOT/WEB-INF/web.xml 
#配置修改后，无需重启tomcat服务，即可观察首页变化
[root@centos8 tomcat]#curl http://127.0.0.1:8080/
```

针对特定APP目录设置专用配置文件

```bash
[root@centos8 tomcat]#cp -a  webapps/ROOT/WEB-INF/   webapps/magedu/
```

**webApp的专有配置优先于系统的全局配置 修改系统的全局配置文件，需要重新启动服务生效 修改 webApp的专有配置，无需重启即可生效**

##### 5.3.4.2应用部署实现

.war：WebApp打包,类zip格式文件,通常包括一个应用的所有资源,比如jsp,html,配置文件等 

.jar：EJB类文件的打包压缩类zip格式文件，包括很多的class文件, 网景公司发明 

传统应用开发测试后，通常打包为war格式，这种文件部署到Tomcat的webapps目录下，并默认会自动 解包展开和部署上线。

```bash
#conf/server.xml中文件配置
<Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">
```

![image-20250428201237419](image-20250428201237419.png)

**部署WebApp的目录结构**

```bash
#目录结构一般由开发用工具自动生成，以下模拟生成相关目录
mkdir projects/myapp/{WEB-INF,META-INF,classes,lib} -pv
 mkdir: 已创建目录 "projects"
 mkdir: 已创建目录 "projects/myapp"
 mkdir: 已创建目录 "projects/myapp/WEB-INF"
 mkdir: 已创建目录 "projects/myapp/META-INF"
 mkdir: 已创建目录 "projects/myapp/classes"
 mkdir: 已创建目录 "projects/myapp/lib"
```

##### 5.3.4.3基于web方式的Host Manager虚拟主机管理

##### 5.3.4.4Context 配置

路径映射：将url映射至指定路径，而非使用appBase下的物理目录，实现虚拟目录功能 

应用独立配置，例如单独配置应用日志、单独配置应用访问控制

##### 5.3.4.5Valve组件

valve(阀门)组件可以定义日志

##### 5.3.4.6实战案例

虚拟主机上利用context实现虚拟目录

基于前面环境,实现软件升级和回滚功能

### 5.4结合反向代理实现 Tomcat 部署

#### 5.4.1常见部署方式介绍

![image-20250429183644203](image-20250429183644203.png)

standalone模式，Tomcat单独运行，直接接受用户的请求，不推荐。

反向代理，单机运行，提供了一个Nginx作为反向代理，可以做到静态由nginx提供响应，动态jsp 代理给Tomcat

LNMT：Linux + Nginx + MySQL + Tomcat 

LAMT：Linux + Apache（Httpd）+ MySQL + Tomcat

前置一台Nginx，给多台Tomcat实例做反向代理和负载均衡调度，Tomcat上部署的纯动态页面更 适合 LNMT：Linux + Nginx + MySQL + Tomcat 

多级代理 LNNMT：Linux + Nginx + Nginx + MySQL + Tomcat

#### 5.4.2利用 Nginx 反向代理至同一个主机的 Tomcat

![image-20250430132237390](image-20250430132237390.png)因此生产中更多的是通过  Nginx 实现HTTPS再反向代理至Tomcat

#### 5.4.3利用 Nginx 实现动静分离代理

```bash
vim  nginx.conf
 root /usr/share/nginx/html;
 #下面行可不加
#location / {
 #    root /data/webapps/ROOT;
 #    index index.html;
 #}
 # ~* 不区分大小写
location ~* \.jsp$ {
    proxy_pass http://node1.wang.org:8080; #注意: 8080后不要加/,需要在nginx服务器修改 
/etc/hosts
}
```

以上设置，可以将jsp的请求反向代理到tomcat，而其它文件仍由nginx处理，从而实现所谓动静分离。

#### 5.4.4利用 Httpd 实现基于 AJP 协议的反向代理至后端 Tomcat 服务器

AJP（Apache JServ Protocol）是定向包协议，是一个二进制的TCP传输协议，相比HTTP这种纯文本的 协议来说，效率和性能更高，也做了很多优化。但是浏览器并不能直接支持AJP13协议，只支持HTTP协 议。所以实际情况是，通过Apache的proxy_ajp模块进行反向代理，暴露成http协议给客户端访问

注意: Tomcat/8.5.51之后版本基于安全需求默认禁用AJP协议

#### 5.4.5实现 Tomcat 负载均衡（Nginx）

**Session sticky 会话黏性**

Session绑定 

nginx：source ip, cookie 

HAProxy：source ip, cookie

缺点：如果目标服务器故障后，如果没有做sessoin持久化，就会丢失session,此方式生产很少使用

**Session 复制集群**

Tomcat自己的提供的多播集群，通过多播将任何一台的session同步到其它节点。

缺点 Tomcat的同步节点不宜过多，互相即时通信同步session需要太多带宽 每一台都拥有全部session，内存损耗太多

**Session Server**

session 共享服务器，使用memcached、redis做共享的Session服务器，此为推荐方式

### 5.5Tomcat Session Replication Cluster

Tomcat 官方实现了 Session 的复制集群,将每个Tomcat的Session进行相互的复制同步,从而保证所有 Tomcat都有相同的Session信息

### 5.6Memcached

memcached 虽然没有像redis所具备的数据持久化功能，比如RDB和AOF都没有，但是可以通过做集群 同步的方式，让各memcached服务器的数据进行同步，从而实现数据的一致性，即保证各memcached 的数据是一样的，即使有任何一台 memcached 发生故障，只要集群中有一台 memcached 可用就不会 出现数据丢失，当其他memcached 重新加入到集群的时候,可以自动从有数据的memcached 当中自动 获取数据并提供服务。

memcached不支持持久化，高可用，value存储容量小

所有的数据存储在物理内存里

非阻塞IO复用模型

性能好

**memcached适用场景：纯KV，数据量非常大，并发量 非常大的业务**

**redis适用场景：复杂数据结构、有持久化、高可用需求、value存储 内容较大**

**内存分配机制**

![image-20250430134524086](image-20250430134524086.png)

**懒过期**

 memcached不会监视数据是否过期，而是在取数据时才看是否过期，如果过期,把数据有效期限标识为 0，并不清除该数据。以后可以覆盖该位置存储其它数据。

**LRU**

当内存不足时，memcached会使用LRU（Least Recently Used）机制来查找可用空间，分配给新记录使用

**集群**

Memcached集群，称为基于客户端 的分布式集群，即由客户端实现集群功能，即Memcached本身不 支持集群 Memcached集群内部并不互相通信，一切都需要客户端连接到Memcached服务器后自行组织这些节 点，并决定数据存储的节点。

官方安装说明

```bash
https://github.com/memcached/memcached/wiki/Install
```

#### memcached 开发库和工具

与memcached通信的不同语言的连接器。libmemcached提供了C库和命令行工具

**memcached 操作命令**

set add replace get delete

### 5.7Session 共享服务器

#### 5.7.1MSM

MSM（memcached session manager）提供将Tomcat的session保持到memcached或Rdis的程序， 可以实现高可用。

#### 5.7.2实战案例 1 : tomcat和memcached集成在一台主机

![image-20250430140635803](image-20250430140635803.png)

**故障访问**

#### 5.7.3实战案例 2 : tomcat和memcached 分别处于不同主机

#### 5.7.4Non-Sticky 模式

non-sticky 模式即前端tomcat和后端memcached无关联(无粘性)关系

从msm 1.4.0之后版本开始支持non-sticky模式。

Tomcat session为中转Session，对每一个SessionID随机选中后端的memcached节点n1(或者n2)为主 session，而另一个memcached节点n2(或者是n1)为备session。产生的新的Session会发送给主、备 memcached，并清除本地Session。

### 5.8Tomcat 性能优化

#### 5.8.1JVM 组成

JVM 组成部分：

类加载子系统: 使用Java语言编写.java Source Code文件，通过javac编译成.class Byte Code文 件。class loader类加载器将所需所有类加载到内存，必要时将类实例化成实例

运行时数据区: 最消耗内存的空间,需要优化

执行引擎: 包括JIT (JustInTimeCompiler)即时编译器, GC垃圾回收器

本地方法接口: 将本地方法栈通过JNI(Java Native Interface)调用Native Method Libraries, 比 如:C,C++库等,扩展Java功能,融合不同的编程语言为Java所用

**JVM运行时数据区域由下面部分构成：**

**Method Area (线程共享)**：方法区是所有线程共享的内存空间，存放已加载的类信息(构造方法,接 口定义),常量(final),静态变量(static), 运行时常量池等。但实例变量存放在堆内存中. 从JDK8开始此 空间由永久代改名为元空间

**heap (线程共享)**：堆在虚拟机启动时创建,存放创建的所有对象信息。如果对象无法申请到可用内 存将抛出OOM异常.堆是靠GC垃圾回收器管理的,通过-Xmx -Xms 指定最大堆和最小堆空间大小

**Java stack (线程私有)**：Java栈是每个线程会分配一个栈，存放java中8大基本数据类型,对象引用, 实例的本地变量,方法参数和返回值等,基于FILO()（First In Last Out）,每个方法为一个栈帧

**Program Counter Register (线程私有)**：PC寄存器就是一个指针,指向方法区中的方法字节码,每 一个线程用于记录当前线程正在执行的字节码指令地址。由执行引擎读取下一条指令.因为线程需要 切换，当一个线程被切换回来需要执行的时候，知道执行到哪里了

**Native Method stack (线程私有)**：本地方法栈为本地方法执行构建的内存空间，存放本地方法 执行时的局部变量、操作数等。

所谓本地方法，使用native 关健字修饰的方法,比如:Thread.sleep方法. 简单的说是非Java实现的方 法，例如操作系统的C编写的库提供的本地方法，Java调用这些本地方法接口执行。但是要注意， 本地方法应该避免直接编程使用，因为Java可能跨平台使用，如果用了Windows API，换到了 Linux平台部署就有了问题

#### 5.8.2GC (Garbage Collection) 垃圾收集器

在堆内存中如果创建的对象不再使用,仍占用着内存,此时即为垃圾.需要即使进行垃圾回收,从而释放内存 空间给其它对象使用

其实不同的开发语言都有垃圾回收问题,C,C++需要程序员人为回收,造成开发难度大,容易出错等问题,但 执行效率高,而JAVA和Python中不需要程序员进行人为的回收垃圾,而由JVM或相关程序自动回收垃圾,减 轻程序员的开发难度,但可能会造成执行效率低下

堆内存里面经常创建、销毁对象，内存也是被使用、被释放。如果不妥善处理，一个使用频繁的进程， 可能会出现虽然有足够的内存容量，但是无法分配出可用内存空间，因为没有连续成片的内存了，内存全是碎片化的空间。

**对于垃圾回收,需要解决三个问题 哪些是垃圾要回收 怎么回收垃圾 什么时候回收垃圾**

##### Garbage 垃圾确定方法

**引用计数**: 每一个堆内对象上都与一个私有引用计数器，记录着被引用的次数，引用计数清零，该 对象所占用堆内存就可以被回收。循环引用的对象都无法将引用计数归零，就无法清除。Python中 即使用此种方式

**根搜索(可达)算法 Root Searching**

**![image-20250501131647089](image-20250501131647089.png)**

##### 垃圾回收基本算法

**标记-清除 Mark-Sweep**

标记阶段，找到所有可访问对象打个标记。清理阶段，遍历整个堆 对未标记对象(即不再使用的对象)逐一进行清理。

缺点：标记-清除最大的问题会造成内存碎片,但是不浪费空间,效率较高(如果对象较多时,逐一删除效率也 会受到影响)

**标记-压缩 (压实)Mark-Compact**

标记阶段，找到所有可访问对象打个标记。 内存清理阶段时，整理时将对象向内存一端移动，整理后存活对象连续的集中在内存一端。

缺点是内存整理过程有消耗,效率相对低下

**复制 Copying**

先将可用内存分为大小相同两块区域A和B，每次只用其中一块，比如A。当A用完后，则将A中存活的对 象复制到B。复制到B的时候连续的使用内存，最后将A一次性清除干净。

好处是没有碎片，复制过程中保证对象使用连续空间,且一次性清除所有垃圾,所以即使对象很多，收回效 率也很高 缺点是比较浪费内存，只能使用原来一半内存，因为内存对半划分了，复制过程毕竟也是有代价

**多种算法总结**

没有最好的算法,在不同场景选择最合适的算法 

效率: 复制算法>标记清除算法> 标记压缩算法 

内存整齐度: 复制算法=标记压缩算法> 标记清除算法 

内存利用率: 标记压缩算法=标记清除算法>复制算法

##### STW

对于大多数垃圾回收算法而言，GC线程工作时，停止所有工作的线程，称为Stop The World。GC 完成 时，恢复其他工作线程运行。这也是JVM运行中最头疼的问题。

##### 分代堆内存GC策略

将heap内存空间分为三个不同类别: 年轻代、老年代、持久代

![image-20250501135815141](image-20250501135815141.png)

**默认空间大小比例:** 

默认JVM试图分配最大内存的总内存的1/4,初始化默认总内存为总内存的1/64,年青代中heap的1/3，老 年代占2/3

![image-20250501140442672](image-20250501140442672.png)

永久代：JDK1.7之前使用, 即Method Area方法区,保存JVM自身的类和方法,存储JAVA运行时的环境信息,  JDK1.8后 改名为 MetaSpace,此空间不存在垃圾回收,关闭JVM会释放此区域内存,此空间物理上不属于 heap内存,但逻辑上存在于heap内存 永久代必须指定大小限制,字符串常量JDK1.7存放在永久代,1.8后存放在heap中 MetaSpace 可以设置,也可不设置,无上限

**规律**: 一般情况99%的对象都是临时对象 

**范例**: 在tomcat 状态页可以看到以下的内存分代

**查看JVM内存分配情况**

```bash
[root@centos8 ~]#cat Heap.java
 public class Heap {
    public static void main(String[] args){
        //返回JVM试图使用的最大内存,字节单位
        long max = Runtime.getRuntime().maxMemory();
        //返回JVM初始化总内存
        long total = Runtime.getRuntime().totalMemory();
        System.out.println("max="+max+"字节\t"+(max/(double)1024/1024)+"MB");
        System.out.println("total="+total+"字节\t"+
 (total/(double)1024/1024)+"MB");
    }
 }
 [root@centos8 ~]#javac Heap.java
 [root@centos8 ~]#java -classpath . Heap
 max=243269632字节 232.0MB
 total=16252928字节    
15.5MB

[root@centos8 ~]#java  -XX:+PrintGCDetails Heap
```

###### 年轻代回收 Minor GC

1. 起始时，所有新建对象(特大对象直接进入老年代)都出生在eden，当eden满了，启动GC。这个称 为Young GC 或者 Minor GC。

2. 先标记eden存活对象，然后将存活对象复制到s0（假设本次是s0，也可以是s1，它们可以调 换），eden剩余所有空间都清空。GC完成。

3. 继续新建对象，当eden再次满了，启动GC。

4. 先同时标记eden和s0中存活对象，然后将存活对象复制到s1。将eden和s0清空,此次GC完成

5. 继续新建对象，当eden满了，启动GC。

6. 先标记eden和s1中存活对象，然后将存活对象复制到s0。将eden和s1清空,此次GC完成

通常场景下,大多数对象都不会存活很久，而且创建活动非常多，新生代就需要频繁垃圾回收。

但是，如果一个对象一直存活，它最后就在from、to来回复制，如果from区中对象复制次数达到阈值 (默认15次,CMS为6次,可通过java的选项 -XX:MaxTenuringThreshold=N 指定)，就直接复制到老年代。

###### 老年代回收 Major GC

进入老年代的数据较少，所以老年代区被占满的速度较慢，所以垃圾回收也不频繁。 如果老年代也满了,会触发老年代GC,称为Old GC或者 Major GC。

由于老年代对象一般来说存活次数较长，所以较常采用标记-压缩算法。

当老年代满时,会触发 Full GC,即对所有"代"的内存进行垃圾回收

Minor GC比较频繁，Major GC较少。但一般Major GC时，由于老年代对象也可以引用新生代对象，所 以先进行一次Minor GC，然后在Major GC会提高效率。可以认为回收老年代的时候完成了一次Full  GC。

所以可以认为 MajorGC = FullGC

##### GC 触发条件

![image-20250501145127704](image-20250501145127704.png)

Full GC 触发条件： 

老年代满了 

System.gc()手动调用。不推荐

年轻代: 存活时长低 适合复制算法

老年代: 区域大,存活时长高 适合标记压缩算法

##### Java 内存调整相关参数

![image-20250501145818763](image-20250501145818763.png)

![image-20250501150837304](image-20250501150837304.png)

```bash
#查看当前命令行的使用的选项设置
[root@centos8 ~]#java -XX:+PrintCommandLineFlags

 #指定内存空间
[root@centos8 ~]#java -Xms1024m -Xmx1024m -XX:+PrintGCDetails Heap
```

查看 OOM

```java
 [root@centos8 ~]#cat  HeapOom2.java
 import java. util. Random;
 public class HeapOom2 {
 public static void main(String[] args) {
 String str = "I am wangxiaochun";
 while (true){
 str += str + new Random().nextInt(88888888); //生成0到8888888之间的随机数字
}
 }
 }

[root@centos8 ~]#javac -cp . HeapOom2.java
    
[root@centos8 ~]#java -Xms100m -Xmx100m -XX:+PrintGCDetails -cp . HeapOom2
```

##### JDK 工具监控使用情况

jvisualvm工具

```bash
#java -cp .  -Xms512m -Xmx1g HelloWorld
```

```java
#测试用java程序
javac HelloWorld.java
java -classpath . -Xms512m -Xmx1g HelloWorld
[root@tomcat ~]#cat HelloWorld.java
public class HelloWorld extends Thread {
   public static void main(String[] args) {
       try {
while (true) {
Thread.sleep(2000);
System.out.println("hello magedu");
}            
       } catch (InterruptedException e) {
           e.printStackTrace();
       }
    }
}
```

![image-20250501153733696](image-20250501153733696.png)

 jvisualvm的 Visual GC 插件

##### Jprofiler定位OOM的问题原因

##### Tomcat的JVM参数设置

默认不指定，-Xmx大约使用了1/4的内存，当前本机内存指定约为1G。

在bin/catalina.sh中增加一行

```bash
JAVA_OPTS="-server  -Xms128m -Xmx512m -XX:NewSize=48m -XX:MaxNewSize=200m"
```

重启 Tomcat 观察

```bash
[root@tomcat ~]#ps aux|grep tomcat
```

![image-20250501154434307](image-20250501154434307.png)

##### 垃圾收集方式

按工作模式不同：指的是GC线程和工作线程是否一起运行

独占垃圾回收器：只有GC在工作，STW 一直进行到回收完毕，工作线程才能继续执行 并发垃圾回收器：让GC线程垃圾回收**某些阶段**可以和工作线程一起进行,如:**标记阶段并行,回收阶段 仍然串行**

按回收线程数：指的是GC线程是否串行或并行执行

串行垃圾回收器：一个GC线程完成回收工作 

并行垃圾回收器：多个GC线程同时一起完成回收工作，充分利用CPU资源

**调整策略**

注意: 在不同领域和场景对JVM需要不同的调整策略 

减少 STW 时长，串行变并行 

减少 GC 次数，要分配合适的内存大小

一般情况下，大概可以使用以下原则：

客户端或较小程序，内存使用量不大，可以使用串行回收

对于服务端大型计算，可以使用并行回收

大型WEB应用，用户端不愿意等待，尽量少的STW，可以使用并发回收

##### 垃圾回收器

优化调整Java 相关参数的目标: 尽量减少FullGC和STW 

通过以下选项可以单独指定新生代、老年代的垃圾收集器

-XX:+UseSerialGC 运行在Client模式下，新生代是Serial, 老年代使用SerialOld

-XX:+UseParNewGC 新生代使用ParNew，老年代使用SerialOld

-XX:+UseParallelGC  运行于server模式下，新生代使用Parallel  Scavenge, 老年代使用 Parallel Old，此为JVM8默 认值，关注吞吐量

-XX:+UseParallelOldGC  新生代使用Paralell Scavenge, 老年代使用Paralell Old，和上面-XX:+UseParallelGC 相同-XX:ParallelGCThreads=N，在关注吞吐量的场景使用此选项增加并行线程

-XX:+UseConcMarkSweepGC 新生代使用ParNew, 老年代优先使用CMS，备选方式为Serial Old 响应时间要短，停顿短使用这个垃圾收集器-XX:CMSInitiatingOccupancyFraction=N，N为0-100整数表示达到老年代的大小的百分比多 少触发回收 默认68-XX:+UseCMSCompactAtFullCollection   开启此值,在CMS收集后，进行内存碎片整理-XX:CMSFullGCsBeforeCompaction=N 设定多少次CMS后，进行一次内存碎片整理-XX:+CMSParallelRemarkEnabled    降低标记

-XX:+UseG1GC  使用GC1的垃圾器器，是JVM11的默认值

```bash
-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=80 
XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=5
```

-XX:+UseG1GC  使用GC1的垃圾器器，是JVM11的默认值

##### JAVA参数总结

#### 5.8.3JVM相关工具

![image-20250501163430474](image-20250501163430474.png)

```bash
#显示java进程
[root@tomcat ~]#jps
 22357 Jps
 21560 Main
 21407 HelloWorld
 
[root@tomcat ~]#jinfo 21407
[root@tomcat ~]#jinfo -flags 21407
 #详细列出当前Java进程信息
[root@tomcat ~]#jps -l -v
```

```bash
[root@tomcat ~]#jstat -gc 21407
S0C:S0区容量
YGC：新生代的垃圾回收次数
YGCT：新生代垃圾回收消耗的时长；
FGC：Full GC的次数
FGCT：Full GC消耗的时长
GCT：GC消耗的总时长

#3次，一秒一次
[root@tomcat ~]#jstat -gcnew 21407 1000 3
```

```bash
#先获得一个java进程PID，然后jinfo
[root@tomcat ~]#jstack -l 21407
```

```bash
jmap
#查看进程堆内存情况
[root@tomcat ~]#jmap -heap 21407

jhat
```

jconsole 和 JMX

JMX最常见的场景是监控Java程序的基本信息和运行情况，任何Java程序都可以开启JMX，然后使用 JConsole或Visual VM进行预览。

#### 5.8.4Tomcat 性能优化常用配置

**内存空间优化**

生产案例：

```bash
JAVA_OPTS="-server -Xms4g -Xmx4g -Xss512k -Xmn1g 
XX:CMSInitiatingOccupancyFraction=65 -XX:+AggressiveOpts -XX:+UseBiasedLocking 
XX:+DisableExplicitGC -XX:MaxTenuringThreshold=10 -XX:NewRatio=2 
XX:PermSize=128m -XX:MaxPermSize=512m -XX:CMSFullGCsBeforeCompaction=5 
XX:+ExplicitGCInvokesConcurrent -XX:+UseConcMarkSweepGC -XX:+UseParNewGC 
XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection 
XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods"
#一台tomcat服务器并发连接数不高,生产建议分配物理内存通常4G到8G较多,如果需要更多连接,一般会利用虚拟化技术实现多台tomcat
```

**线程池调整**

```bash
[root@centos8 ~]#vim /usr/local/tomcat/conf/server.xml
 ......
 <Connector port="8080" protocol="HTTP/1.1"  connectionTimeout="20000" 
redirectPort="8443"  maxThreads="2000"/>
 ......
```

### 5.9Java 程序编译

以 Github 上 Java 开源项目 dubbo-admin 为例

```bash
https://github.com/apache/dubbo-admin/
```

```bash
Production Setup
Clone source code on develop branch git clone https://github.com/apache/dubbo
admin.git
Specify registry address in dubbo-admin
server/src/main/resources/application.properties
Build
mvn clean package -Dmaven.test.skip=true
Start
mvn --projects dubbo-admin-server spring-boot:run
OR
cd dubbo-admin-distribution/target; java -jar dubbo-admin-0.1.jar
Visit http://localhost:8080
Default username and password is root
```

#### 5.9.1Maven 部署

Maven 是一个项目管理工具，可以对 Java项目进行构建、解决打包依赖等。

```bash
https://maven.apache.org/
http://repo.maven.apache.org/
```

```bash
#官方
https://maven.apache.org/download.cgi
 #清华镜像源
http://mirrors.tuna.tsinghua.edu.cn/apache/maven
 #官方各版本下载地址，推荐使用次新版本
https://archive.apache.org/dist/maven/maven-3
```

注意: Maven所安装JDK的版本不影响编译应用的所依赖的JDK版本,比如Maven安装JDK11,而java应用  Jpress 可以使用JDK8

#### 5.9.2maven 安装

```bash
[root@ubuntu2204 ~]#apt update;apt -y  install maven
[root@ubuntu2204 ~]#mvn -version

[root@ubuntu2004 ~]#apt -y install maven
 #自动安装Openjdk11
[root@ubuntu2004 ~]#java -version

[root@ubuntu2004 ~]#mvn -v

 #镜像加速
[root@ubuntu2004 ~]#vim /etc/maven/settings.xml
 #大约在159行
......
  <mirrors>
    <!--阿里云镜像-->
    <mirror>
        <id>nexus-aliyun</id>
        <mirrorOf>*</mirrorOf>
        <name>Nexus aliyun</name>  <url>http://maven.aliyun.com/nexus/content/groups/public</url>
    </mirror>                                                                     
  </mirrors>
 ......
```

#### 5.9.3Maven 的打包命令说明

```bash
#启用多线程编译：
mvn clean install package -Dmaven.test.skip=true -Dmaven.compile.fork=true
#所有的 Maven 都是建立在 JVM 上的，所以进行编译的时候还需要考虑JVM 参数优化：
#打开属性配置文件：
vim /etc/profile
#指定内存配置：
export MAVEN_OPTS="-Xmx6g -Xms6g" 注意不要超过物理内存一半
#使配置立即生效：
source /etc/profile
```

#### 5.9.4Java 源代码编译

```bash
[root@ubuntu1804 ~]#apt -y install maven git 
#镜像加速
[root@ubuntu1804 ~]#vim /etc/maven/settings.xml

[root@ubuntu1804 data]#git clone https://gitee.com/lbtooth/spring-boot-helloWorld.git
[root@ubuntu1804 data]#cd spring-boot-helloWorld/

#默认为8080端口
[root@ubuntu1804 spring-boot-helloWorld]#java -jar target/spring-boot-helloworld-0.9.0-SNAPSHOT.jar --server.port=8888

```

编译 java 程序 Jpress

#### 5.9.5私有仓库 Nexus

Nexus 是一个强大的 Maven 和其它仓库的管理器，它极大地简化了自己内部仓库的维护和外部仓库的访问。

```bash
https://www.sonatype.com/
https://help.sonatype.com/repomanager3/download
```

```bash
https://help.sonatype.com/repomanager3/download/download-archives---repositorymanager-3
官方安装文档链接
https://help.sonatype.com/repomanager3/installation-and-upgrades/installationmethods
#官方要求内存8G以上，太小比如4G以下会导致无法启动
https://help.sonatype.com/repomanager3/installation/system-requirements
```

Docker 安装

```bash
docker run -d -p 8081:8081 --name nexus sonatype/nexus3
```

**部署 Nexus**

安装Nexus建议内存至少4G以上

默认仓库有以下 type 类型

```bash
Hosted：本地仓库，通常我们会部署自己的构件到这一类型的仓库，比如公司的第三方库
Proxy：代理仓库，它们被用来代理远程的公共仓库，如maven 中央仓库(官方仓库)
Group：仓库组，用来合并多个 hosted/proxy 仓库，当你的项目希望在多个repository 使用资源时就不需要多次引用了，只需要引用一个 group 即可
```

**Maven的仓库优化配置**

默认仓库maven-central使用国外仓库地址,可修改为如下的国内镜像地址进行加速

```bash
http://maven.aliyun.com/nexus/content/groups/public
https://maven.aliyun.com/mvn/guide
```

在Maven配置文件指定Nexus服务器地址，后续进行JAVA源码编译可以从Nexus仓库下载相关包

```bash
[root@ubuntu2204 ~]#vim /etc/maven/settings.xml
 ......
  <mirror>
        <id>nexus-m51</id>
        <mirrorOf>*</mirrorOf>
        <name>Nexus m51</name>
        <url>http://nexus.wang.org:8081/repository/maven-central/</url>
    </mirror>
 </mirrors>

#后续的编译就会从nexus服务器下载相关包
[root@ubuntu2204 spring-boot-helloWorld]#mv package
```

**使用 Nexus 构建私有 Yum 和 Apt 仓库**

```bash
setting--Create repository—yum(proxy)
```

![image-20250502150218250](image-20250502150218250.png)

将 Nexus 服务仓库配置为yum仓库

```bash
[root@centos7 ~]#cat > /etc/yum.repos.d/zabbix.repo <<EOF
 > [zabbix-nexus]
 > name=zabbix-nexus
 > baseurl=http://10.0.0.100:8081/repository/zabbix-5.0-yum-centos7/
 > gpgcheck=0
 > EOF
[root@centos7 ~]#yum repolist
```

面试题

Session 会话保持有几种解决方案 

JVM的组成 

JVM中堆Heap分代 

JVM的常见垃圾回收器 

JVM的常见启动参数 

JAVA程序出现OOM,如何解决 

Tomcat的优化方法 

Java 应用源码编译如何实现

## 6.企业级反向代理HAProxy

### 6.1Web 架构介绍

![image-20250517170849319](./image-20250517170849319.png)

### 6.2HAProxy简介

阿里云SLB介绍 ： https://yq.aliyun.com/articles/1803

负载均衡：Load Balance，简称 LB，是一种服务或基于硬件设备等实现的高可用反向代理技术，负载 均衡将特定的业务(web服务、网络流量等)分担给指定的一个或多个后端特定的服务器或设备，从而提高 了公司业务的并发处理能力、保证了业务的高可用性、方便了业务后期的水平动态扩展

**应用场景**

四层：Redis、Mysql、RabbitMQ、Memcached等 

七层：Nginx、Tomcat、Apache、PHP、图片、动静分离、API等

随着公司业务的发展，公司负载均衡服务既有四层的，又有七层的，通过LVS实现四层和Nginx实现七层 的负载均衡对机器资源消耗比较大，并且管理复杂度提升，运维总监要求，目前需要对前端负载均衡服 务进行一定的优化和复用，能否用一种服务同既能实现七层负载均衡，又能实现四层负载均衡，并且性 能高效，配置管理容易，而且还是开源。

### 6.3安装

#### 1 Ubuntu 包安装

打开链接： https://haproxy.debian.net/ ，选择合适的版本，会自动出现下面安装提示

#### 2 RHEL系统包安装

系统默认yum源版本比较旧

```bash
[root@rocky8 ~]#yum list haproxy
```

第三方安装包

官方没有提供rpm相关的包,可以通过第三方仓库的rpm包 

从第三方网站下载rpm包： https://pkgs.org/download/haproxy

```bash
#wget http://www.nosuchhost.net/~cheese/fedora/packages/epel-7/x86_64/cheese-release-7-1.noarch.rpm
 #rpm -ivh cheese-release-7-1.noarch.rpm
 #yum install haproxy
 #验证haproxy版本
# haproxy  -v
```

#### 3.编译安装 HAProxy

编译安装HAProxy 2.0 LTS版本，更多源码包下载地址： http://www.haproxy.org/download/

**解决 lua 环境 (可选)**

CentOS 基础环境  

参考链接： http://www.lua.org/start.html

由于CentOS7 之前版本自带的lua版本比较低并不符合HAProxy要求的lua最低版本(5.3)的要求，因此需 要编译安装较新版本的lua环境，然后才能编译安装HAProxy，过程如下：

```bash
#当前系统版本
[root@centos7 ~]#lua -v 
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
 #安装基础命令及编译依赖环境
[root@centos7 ~]# yum install gcc readline-devel
 [root@centos7 ~]# wget http://www.lua.org/ftp/lua-5.3.5.tar.gz
 [root@centos7 ~]# tar xvf  lua-5.3.5.tar.gz -C /usr/local/src
 [root@centos7 ~]# cd /usr/local/src/lua-5.3.5
 [root@centos7 lua-5.3.5]# make linux test
 #查看编译安装的版本
[root@centos7 lua-5.3.5]#src/lua -v
```

Ubuntu的Lua版本较新，也可以用包安装

Ubuntu 基础环境

```bash
#安装基础命令及编译依赖环境
[root@ubuntu2204 ~]#apt update && apt -y install gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libsystemd-dev liblua5.4-dev
 [root@ubuntu1804 ~]#apt update && apt -y install gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libsystemd-dev 
```

**验证HAProxy版本**

```bash
[root@centos7 ~]#haproxy  -v
```

**准备用户**

```bash
#设置用户和目录权限
[root@centos7 ~]# useradd  -m -r -s /sbin/nologin -d /var/lib/haproxy haproxy
```

**配置文件**

```bash
#准备配置文件
[root@centos7 ~]# mkdir  /etc/haproxy
#方式1:复制源码中的范例配置文件做为初始配置文件
[root@haproxy haproxy-2.8.3]#cp examples/quick-test.cfg  
/etc/haproxy/haproxy.cfg

 #方式2:创建自定义的配置文件
[root@centos7 ~]# vim /etc/haproxy/haproxy.cfg 

#准备HAProxy启动文件
#创建service文件
[root@centos7 ~]#vim  /usr/lib/systemd/system/haproxy.service
 [Unit]
 Description=HAProxy Load Balancer
 After=syslog.target network.target
 [Service]
 ExecStartPre=/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg  -c -q
 ExecStart=/usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p 
/var/lib/haproxy/haproxy.pid
 ExecReload=/bin/kill -USR2 $MAINPID
 LimitNOFILE=100000
 [Install]
 WantedBy=multi-user.target
```

**启动 haproxy**

```bash
[root@centos7 ~]# systemctl  enable --now haproxy
[root@centos7 ~]# systemctl status haproxy
```

**查看haproxy的状态页面**

http://haproxy-server:9999/haproxy-status

#### 4.基于 Docker 部署

```bash
https://hub.docker.com/_/haproxy/
```

### 6.4HAProxy 基础配置

官方文档： http://cbonte.github.io/haproxy-dconv/ 

http://cbonte.github.io/haproxy-dconv/2.1/configuration.html

HAProxy 的配置文件haproxy.cfg由两大部分组成，分别是global和proxies部分

**global：全局配置段**

进程及安全配置相关的参数 性能调整相关参数 Debug参数

**proxies：代理配置段**

```bash
defaults：为frontend, backend, listen提供默认配置
listen：同时拥有前端和后端配置,配置简单,生产推荐使用
frontend：前端，相当于nginx中的server {}
backend：后端，相当于nginx中的upstream {}
```

#### 6.4.1global配置

官方文档： http://cbonte.github.io/haproxy-dconv/2.6/configuration.html#3 

http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#3

##### 多进程和线程

从2.5以上新版中用多线程代替多worker进程

多线程和CPU绑定

```bash
#范例1
 [root@haproxy ~]#vim /etc/haproxy/haproxy.cfg
 global
     nbthread  8  #默认为auto,即自动生成CPU核数的相同的线程
     cpu-map auto:1/1-8 0-7
     
 #语法检查
[root@haproxy ~]#haproxy  -c  -f  /etc/haproxy/haproxy.cfg
[root@haproxy ~]#systemctl restart haproxy.service

 #查看CPU和线程之间的绑定关系
[root@haproxy ~]#apt -y install sysstat
[root@haproxy ~]#pidstat -p 915  -t

#范例2
[root@haproxy ~]#vim /etc/haproxy/haproxy.cfg
#自动生成和CPU核相同的线程数，并做绑定
cpu-map auto:1/1-4 0-3
#查看CPU和线程之间的绑定关系
[root@haproxy ~]#ps  axo pid,cmd,psr -L  |grep haproxy
```

##### HAProxy日志配置

 HAproxy默认本身不记录客户端的访问日志.此外为减少服务器负载,一般生产中HAProxy不记录日志.

```bash
#在global配置项定义：
log 127.0.0.1:514  local{0-7} info #基于syslog记录日志到指定设备，级别包括:err、warning、info、debug
  listen  web_port
  bind 127.0.0.1:80
  mode http
  log global        
#开启当前web_port的日志功能，默认不记录日志
  server web1  127.0.0.1:8080  check inter 3000 fall 2 rise 5
 # systemctl  restart haproxy

```

**Rsyslog配置**

```bash
vim /etc/rsyslog.conf 
$ModLoad imudp
$UDPServerRun 514
......
local3.*    /var/log/haproxy.log
......
# systemctl  restart rsyslog
```

**验证HAProxy日志**

如果日志无法生成,可能需要重启服务器

```bash
# tail -f /var/log/haproxy.log 
```

**启动本地和远程日志**

#### 6.4.2Proxies 配置

官方文档： https://docs.haproxy.org/2.8/configuration.html#4.1 

http://cbonte.github.io/haproxy-dconv/2.1/configuration.html#4

```bash
defaults [<name>] #默认配置项，针对以下的frontend、backend和listen生效，可以多个name也可以没有name
listen   <name>   #将frontend和backend合并在一起配置，相对于frontend和backend配置更简洁，生产常用
frontend <name>   #前端servername，类似于Nginx的一个虚拟主机 server和LVS服务集群。
backend  <name>   #后端服务器组，等于nginx的upstream和LVS中的RS服务器

```

![image-20250519180548782](./image-20250519180548782.png)

##### Proxies配置 listen

使用listen替换 frontend和backend的配置方式，可以简化设置，常用于TCP协议的应用

server 配置

![image-20250519184312258](./image-20250519184312258.png)

![image-20250519184322227](./image-20250519184322227.png)

![image-20250519184251105](./image-20250519184251105.png)

##### Proxies配置 frontend

![image-20250519184402200](./image-20250519184402200.png)

![image-20250519184455518](./image-20250519184455518.png)

##### Proxies配置 backend

![image-20250519184814050](./image-20250519184814050.png)

![image-20250519184842979](./image-20250519184842979.png)

##### 使用子配置文件

```bash
#创建子配置目录
[root@centos7 ~]#mkdir /etc/haproxy/conf.d/
#添加子配置目录到unit文件中
[root@centos7 ~]#vim  /lib/systemd/system/haproxy.service
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target
[Service]
#修改下面两行
ExecStartPre=/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/ -c -q
ExecStart=/usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/  -p /var/lib/haproxy/haproxy.pid
ExecReload=/bin/kill -USR2 $MAINPID
[Install]
WantedBy=multi-user.target
#创建子配置文件，注意：必须为cfg后缀非.开头的配置文件
[root@centos7 ~]#vim   /etc/haproxy/conf.d/test.cfg
 listen WEB_PORT_80
 bind 10.0.0.7:80
 mode http
 balance roundrobin
 server web1  10.0.0.17:80  check inter 3000 fall 2 rise 5
 server web2  10.0.0.27:80  check inter 3000 fall 2 rise 5
[root@centos7 ~]#systemctl daemon-reload 
[root@centos7 ~]#systemctl restart haproxy
```

### 6.5HAProxy 调度算法

官方文档： http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-balance

#### 6.5.1Socat 工具

对服务器动态权重和其它状态可以利用 socat 工具进行调整，Socat 是 Linux 下的一个多功能的网络工 具，名字来由是Socket CAT，相当于netCAT的增强版.Socat 的主要特点就是在两个数据流之间建立双向 通道，且支持众多协议和链接方式。如 IP、TCP、 UDP、IPv6、Socket文件等

**利用工具socat 对服务器动态权重调整**

```bash
#安装socat
 [root@ubuntu1804 ~]#apt update && apt -y install socat
 [root@centos ~]#yum -y install socat
 #提前配置socket文件路径
[root@ubuntu2204 ~]#vim /etc/haproxy/haproxy.cfg
 global
   stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
 #查看帮助
[root@centos7 ~]#socat -h
 [root@centos7 ~]#echo "help" | socat stdio /var/lib/haproxy/haproxy.sock
```

```bash
#可以用于实现Zabbix监控
[root@centos7 ~]#echo "show info" | socat stdio /var/lib/haproxy/haproxy.sock
```

```bash
#获取当前连接数
[root@haproxy ~]#echo "show info" | socat stdio /var/lib/haproxy/haproxy.sock | 
awk '/CurrConns/{print $2}'
```

```bash
[root@centos7 ~]#echo "show servers state" | socat stdio 
/var/lib/haproxy/haproxy.sock
```

详细使用看文档

#### 6.5.2静态算法

静态算法：按照事先定义好的规则轮询进行调度，不关心后端服务器的当前负载、连接数和响应速度 等，且无法实时动态修改权重(只能动态修改为0下线和100%上线,不支持其它值)或者修改后不生效，**如果需要修改权重只能靠重启HAProxy生效**。

##### static-rr 算法

static-rr：基于权重的轮询调度，不支持运行时利用socat进行权重的动态调整(只支持0和1,不支持其它 值)及后端服务器慢启动，其后端主机数量没有限制，相当于LVS中的 wrr

**first 算法**

first：根据服务器在列表中的位置，自上而下进行调度，但是其只会当第一台服务器的连接数达到上 限，新请求才会分配给下一台服务，因此会忽略服务器的权重设置，**此方式使用较少**

#### 6.5.3动态算法

动态算法：基于后端服务器状态进行调度适当调整，新请求将优先调度至当前负载较低的服务器，且权 重可以在haproxy运行时动态调整无需重启。

##### roundrobin 算法

roundrobin：基于权重的轮询动态调度算法，支持权重的运行时调整，不同于lvs中的rr轮训模式， HAProxy中的roundrobin支持慢启动(新加的服务器会逐渐增加转发数)，其每个后端backend中最多支 持4095个real server，支持对real server权重动态调整

**roundrobin为默认调度算法,此算法使用广泛**

```bash
listen  web_host
  bind 10.0.0.7:80,:8801-8810,10.0.0.7:9001-9010
  mode http
  log global
  balance roundrobin
  server web1  10.0.0.17:80 weight 1  check inter 3000 fall 2 rise 5
  server web2  10.0.0.27:80 weight 2  check inter 3000 fall 2 rise 5
```

支持动态调整权重：

```bash
# echo "get weight web_host/web1" | socat stdio /var/lib/haproxy/haproxy.sock 
1 (initial 1)
 # echo "set weight web_host/web1 3" | socat stdio /var/lib/haproxy/haproxy.sock 
# echo "get weight web_host/web1" | socat stdio /var/lib/haproxy/haproxy.sock 
3 (initial 1)
```

##### leastconn 算法

leastconn 加权的最少连接的动态，支持权重的运行时调整和慢启动，即根据当前连接最少的后端服务 器而非权重进行优先调度(新客户端连接)，比较适合长连接的场景使用，比如：MySQL等场景。

相当于LVS中的WLC算法

```bash
listen  web_host
  bind 10.0.0.7:80,:8801-8810,10.0.0.7:9001-9010
  mode http
  log global
  balance leastconn
  server web1  10.0.0.17:80 weight 1  check inter 3000 fall 2 rise 5
  server web2  10.0.0.27:80 weight 1  check inter 3000 fall 2 rise 
```

##### random 算法

在1.9版本开始增加 random的负载平衡算法，其基于随机数作为一致性hash的key，随机负载平衡对于 大型服务器场或经常添加或删除服务器非常有用，支持weight的动态调整，weight较大的主机有更大概 率获取新请求 random配置实例

```bash
listen  web_host
  bind 10.0.0.7:80,:8801-8810,10.0.0.7:9001-9010
  mode http
  log global
  balance  random
  server web1  10.0.0.17:80 weight 1  check inter 3000 fall 2 rise 5
  server web2  10.0.0.27:80 weight 1  check inter 3000 fall 2 rise 5
```

#### 6.5.4其他算法

##### source 算法

源地址hash，基于用户源地址hash并将请求转发到后端服务器，后续同一个源地址请求将被转发至同一 个后端web服务器。

**map-base** 

此方法是静态的

取模法  map-based：取模法，对source地址进行hash计算，再基于服务器总权重的取模，最终结果决定将此 请求转发至对应的后端服务器。

**一致性 hash**

##### uri 算法

基于对用户请求的URI的左半部分/path部分做hash运算，再将hash结果对总权重进行取模后，根据最 终结果将请求转发到后端指定服务器，适用于后端是缓存服务器场景，默认是静态算法，也可以通过 hash-type指定map-based和consistent，来定义使用取模法还是一致性hash。

##### url_param 算法

url_param对用户请求的url中的 params 部分中的一个参数key对应的value值作hash计算，并由服务器 总权重相除以后派发至某挑出的服务器；通常用于追踪用户，以确保来自同一个用户的请求始终发往同 一个real server，如果无没key，将按roundrobin算法

##### hdr 算法

**针对用户每个http头部(header)请求中的指定信息做hash**，此处由 name 指定的http首部将会被取出并 做hash计算，然后由服务器总权重取模以后派发至某挑出的服务器，如果无有效值，则会使用默认的轮 询调度。

##### rdp-cookie 算法

rdp-cookie对远 Windows远程桌面的负载，使用cookie保持会话，默认是静态，也可以通过hash-type 指定map-based和consistent，来定义使用取模法还是一致性hash

#### 6.5.5算法总结

```bash
#静态
static-rr--------->tcp/http  
first------------->tcp/http  

#动态
roundrobin-------->tcp/http 
leastconn--------->tcp/http 
random------------>tcp/http
 
#以下静态和动态取决于hash_type是否consistent
source------------>tcp/http
Uri--------------->http
url_param--------->http     
hdr--------------->http
rdp-cookie-------->tcp


#各种算法使用场景
first       
#使用较少
static-rr   
#做了session共享的 web 集群
roundrobin  #默认值
random
 leastconn   
source      
hdr         
#数据库

#基于客户端公网 IP 的会话保持
Uri--------------->http  #缓存服务器，CDN服务商，蓝汛、百度、阿里云、腾讯
url_param--------->http  #可以实现session保持
#基于客户端请求报文头部做下一步处理
rdp-cookie  #基于Windows主机,很少使用
```

### 6.6HAProxy 高级功能

#### 6.6.1基于 Cookie 的会话保持  

cookie  value：为当前server指定cookie值，实现基于cookie的会话黏性，相对于基于 source 地址  hash 调度算法对客户端的粒度更精准，但同时也加重了haproxy负载，目前此模式使用较少， 已经被 session共享服务器代替 注意：不支持 tcp mode，使用 http mode

![image-20250519194525644](./image-20250519194525644.png)

#### 6.6.2HAProxy 状态页

通过web界面，显示当前HAProxy的运行状态 官方帮助： http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-stats%20admin 

http://cbonte.github.io/haproxy-dconv/2.0/configuration.html#4-stats%20admin

![image-20250519194620950](./image-20250519194620950.png)

![image-20250519194649303](./image-20250519194649303.png)

**Backend Server 信息说明**

![image-20250519194726303](./image-20250519194726303.png)

**利用状态页实现haproxy服务器的健康性检查**

通过curl 命令对haproxy的状态页的访问实现健康检查

```bash
[root@haproxy ~]#curl -s -f  http://admin:123456@10.0.0.200:8888/status -I
 #密码错误
[root@haproxy ~]#curl -sf  http://admin:12346@10.0.0.200:9999/haproxy-status 
[root@centos8 ~]#curl -I -m 1  http://haadmin:123456@10.0.0.7:9999/haproxy-status


```

#### 6.6.3IP透传

web服务器中需要记录客户端的真实IP地址，用于做访问统计、安全防护、行为分析、区域排行等场景。

**Layer 4 与 Layer 7**

四层：IP+PORT转发 

七层：协议+内容交换

**四层负载**

在LVS 传统的四层负载设备中，把client发送的报文目标地址(原来是负载均衡设备的IP地址)，根据均衡 设备设置的选择web服务器的规则选择对应的web服务器IP地址，这样client就可以直接跟此服务器建立 TCP连接并发送数据，而四层负载自身不参与建立连接 

而和LVS不同，haproxy是伪四层负载均衡，因为haproxy 需要分别和前端客户端及后端服务器建立连接

**七层代理**

七层负载均衡服务器起了一个反向代理服务器的作用，服务器建立一次TCP连接要三次握手，而client要 访问Web Server要先与七层负载设备进行三次握手后建立TCP连接，把要访问的报文信息发送给七层负 载均衡；然后七层负载均衡再根据设置的均衡规则选择特定的 Web Server，然后通过三次握手与此台  Web Server建立TCP连接，然后Web Server把需要的数据发送给七层负载均衡设备，负载均衡设备再把 数据发送给client；所以，七层负载均衡设备起到了代理服务器的作用，七层代理需要和Client和后端服 务器分别建立连接

```bash
[root@haproxy ~]#tcpdump  tcp  -i eth0   -nn port ! 22  -w dump-tcp.pcap  -v
[root@haproxy ~]#tcpdump  tcp  -i eth1   -nn port ! 22  -w dump-tcp2.pcap -v
```

##### 四层IP透传

![image-20250519195443647](./image-20250519195443647.png)

抓包可以看到 continuation 信息中带有客户端的源IP

**nginx 开启四层日志功能**

```bash
#nginx在开启proxy_protocol后，可以看客户端真实源IP
 [root@VM_0_10_centos ~]# tail -f /apps/nginx/logs/nginx.access.log
 111.199.187.69 - - [09/Apr/2020:20:52:52 +0800] "GET / HTTP/1.1" 
"172.16.0.200"sendfileon
```

##### 七层IP透传

当haproxy工作在七层的时候，也可以透传客户端真实IP至后端服务器

在由haproxy发往后端主机的请求报文中添加“X-Forwarded-For"首部，其值为前端客户端的地址；用于 向后端主发送真实的客户端IP

```bash
#haproxy 配置
defaults
#此为默认值,首部字段默认为：X-Forwarded-For
option  forwardfor   
#或者自定义首部,如:X-client
option forwardfor except 127.0.0.0/8 header X-client
#listen配置
listen  web_host
  bind 10.0.0.7:80
  mode http      #一定是http模式,tcp 模式不会传递客户端IP
  log global
  balance  random
  server web1 10.0.0.17:80 weight 1  check inter 3000 fall 2 rise 5
  server web2 10.0.0.27:80 weight 1  check inter 3000 fall 2 rise 5
```

**后端 Web 服务器日志格式配置**

配置web服务器，记录负载均衡透传的客户端IP地址

```bash
#nginx 日志格式：默认就支持
$proxy_add_x_forwarded_for：包括客户端IP和中间经过的所有代理的IP
$http_x_forwarded_For：只有客户端IP
log_format  main  '"$proxy_add_x_forwarded_for" - $remote_user [$time_local] 
"$request" '
'$status $body_bytes_sent "$http_referer" '
'"$http_user_agent" $http_x_forwarded_For';
```



```bash
官方文档：参看2.4的帮助文档
http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-http-request
http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-http-response
```

#### 6.6.4报文修改

官方文档：参看2.4的帮助文档 http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-http-request 

http://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4-http-response

#### 6.6.5自定义日志格式

#### 6.6.6压缩功能

#### 6.6.7后端服务器健康性监测

#### 6.6.8ACL

```bash
官方帮助：
http://cbonte.github.io/haproxy-dconv/2.1/configuration.html#7
http://cbonte.github.io/haproxy-dconv/2.0/configuration.html#7
```

#### 6.6.9自定义 HAProxy 错误界面

#### 6.6.10HAProxy 四层负载

#### 6.6.11HAProxy Https 实现

### 6.7重点总结  

HAProxy调度算法 

ACL使用与报文修改 

动静分离(根据文件后缀或URL) 

客户端源IP透传 

服务器动态下线 

编写shell脚本，实现能够基于参数传递 Real Server 服务器IP，并实现将其从多个HAProxy进程下 线与上线 

比较LVS,haproxy,nginx三者的特性和调度算法区别(面试题)

## 7.高可用集群 KEEPALIVED

### 7.1高可用集群

#### 7.1.1集群类型

LB：Load Balance 负载均衡

HA：High Availability 高可用集群

HPC：High Performance Computing 高性能集群

#### 7.1.2系统可用性

A = MTBF  / (MTBF+MTTR） 

MTBF:Mean Time Between Failure 平均无故障时间，正常时间 

MTTR:Mean Time To Restoration（ repair）平均恢复前时间，故障时间

### 7.2Keepalived 架构和安装

官方文档： https://keepalived.org/doc/ 

http://keepalived.org/documentation.html 

vrrp 协议的软件实现，原生设计目的为了高可用 ipvs服务 

keepalived 是高可用集群的通用无状态应用解决方案

官网： http://keepalived.org/

功能： 

基于vrrp协议完成IP地址流动 

为vip地址所在的节点生成ipvs规则(在配置文件中预先定义) 

为ipvs集群的各RS做健康状态检测 

基于脚本调用接口完成脚本中定义的功能，进而影响集群事务，以此支持实现nginx、haproxy等 服务的高可用

![image-20250519205114208](./image-20250519205114208.png)

#### 7.2.1Keepalived 环境准备

![image-20250519205640726](./image-20250519205640726.png)

![image-20250519205754883](./image-20250519205754883.png)

#### 7.2.2安装方法 

包安装 

编译安装 

容器运行

### 7.3KeepAlived 配置说明

配置文件 /etc/keepalived/keepalived.conf

配置文件组成 

GLOBAL CONFIGURATION Global definitions：定义邮件配置，route_id，vrrp配置，多播地址等 VRRP 

CONFIGURATION VRRP instance(s)：定义每个vrrp虚拟路由器 

LVS CONFIGURATION Virtual server group(s) Virtual server(s)：LVS集群的VS和RS

#### 7.3.1全局配置

![image-20250519210607296](./image-20250519210607296.png)

#### 7.3.2启用 Keepalived 日志功能

默认 keepalived的日志记录在LOG_DAEMON中，记录在/var/log/syslog或messages, 也支持自定义日 志配置

#### 7.3.3实现 Keepalived 独立子配置文件

当生产环境复杂时， /etc/keepalived/keepalived.conf 文件中保存所有集群的配置会导致内容过 多，不易管理 可以将不同集群的配置，比如：不同集群的VIP配置放在独立的子配置文件中

```bash
 include /path/file
```

```bash
[root@ka1 ~]#mkdir /etc/keepalived/conf.d/
 [root@ka1 ~]#vim /etc/keepalived/keepalived.conf
 global_defs {
   notification_email {
 29308620@qq.com
   }
   notification_email_from 29308620@qq.com 
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id ka1.wang.org 
   vrrp_skip_check_adv_addr
   vrrp_garp_interval 0
   vrrp_gna_interval 0
 }
 include /etc/keepalived/conf.d/*.conf   
#将VRRP相关配置放在子配置文件中
```

### 7.4Keepalived 实现 VRRP

#### 7.4.1实现Master/Backup的 Keepalived 单主架构

![image-20250519211503294](./image-20250519211503294.png)

#### 7.4.2抢占模式和非抢占模式

##### 1 非抢占模式 nopreempt

默认为抢占模式 preempt，即当高优先级的主机恢复在线后，会抢占低先级的主机的master角色，造成 网络抖动，建议设置为非抢占模式 nopreempt ，即高优先级主机恢复后，并不会抢占低优先级主机的  master 角色

注意: 非抢占模式下,如果原主机down机, VIP迁移至的新主机, 后续新主机也发生down（（keepalived  服务down））时,VIP还会迁移回修复好的原主机

![image-20250520165658041](./image-20250520165658041.png)

##### 2 抢占延迟模式 preempt_delay

抢占延迟模式，即优先级高的主机恢复后，不会立即抢回VIP，而是延迟一段时间（默认300s）再抢回  VIP

![image-20250520170305610](./image-20250520170305610.png)

#### 7.4.3 VIP 单播配置

默认keepalived主机之间利用多播相互通告消息，会造成网络拥塞，可以设置为单播，减少网络流量 另外：有些公有云不支持多播，可以利用单播实现 单播优先与多播，即同时配置，单播生效

注意：启用 vrrp_strict 时，不能启用单播

```powershell
global_defs {
    router_id kpmaster
    # 自定义多播地址（不写则默认 224.0.0.18）
    vrrp_mcast_group4 226.0.0.18
}

vrrp_instance VI_1 {
    state MASTER
    interface ens37
    virtual_router_id 50
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.8.100/24
    }
}

```

```powershell
global_defs {
    router_id kpmaster
}

vrrp_instance VI_1 {
    state MASTER
    interface ens37
    virtual_router_id 50
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.8.100/24
    }

    # 启用单播模式
    unicast_src_ip 192.168.8.11          # 本机IP
    unicast_peer {
        192.168.8.12                     # # 同 VLAN 备节点
        192.168.9.12
    }
}

```

#### 7.4.4 Keepalived 通知脚本配置

当keepalived的状态变化时，可以自动触发脚本的执行，比如：发邮件通知用户 默认以用户keepalived_script身份执行脚本，如果此用户不存在，以root执行脚本

##### **实现 Keepalived 状态切换的通知脚本**



#### 7.4.5 脑裂现象

主备节点同时拥有同一个VIP，此时为脑裂现象 

注意：脑裂现象原因 

心跳线故障： 注意:在虚拟机环境中测试可以通过修改网卡的工作模式实现模拟，断开网卡方式无 法模拟 

防火墙错误配置：在从节点服务器执行iptables -A INPUT -s 主服务心跳网卡IP -j DROP 进行模拟 

Keepalived 配置错误：多播或单播地址不同，interface错误，virtual_router_id不一致，密码不一 致

```bash
[root@centos7 ~]#arping  -I eth1 -c1 10.0.0.100
```

#### 7.4.6实现 Master/Master 的 Keepalived 双主架构

即将两个或以上VIP分别运行在不同的keepalived服务器，以实现服务器并行提供web访问的目的，提高 服务器资源利用率

master/slave的单主架构，同一时间只有一个Keepalived对外提供服务，此主机繁忙，而另一台主机却 很空闲，利用率低下，可以使用master/master的双主架构，解决此问题。

#### 7.4.7实现多主模架构

##### 案例：三个节点的三主三从架构实现

![image-20250520204110612](./image-20250520204110612.png)

```bash
#第一个节点ka1配置：
virtual_router_id 1 , Vrrp instance 1 , MASTER，优先级 100
virtual_router_id 3 , Vrrp instance 2 , BACKUP，优先级 80
#第二个节点ka2配置：
virtual_router_id 2 , Vrrp instance 1 , MASTER，优先级 100
virtual_router_id 1 , Vrrp instance 2 , BACKUP，优先级 80
#第三个节点ka3配置：
virtual_router_id 3 , Vrrp instance 1 , MASTER，优先级 100
virtual_router_id 2 , Vrrp instance 2 , BACKUP，优先级 80
```

##### 案例：三个节点的三主六从架构实现

![image-20250520204119534](./image-20250520204119534.png)

```bash
#第一个节点ka1配置：
virtual_router_id 1 , Vrrp instance 1 , MASTER，优先级100
 virtual_router_id 2 , Vrrp instance 2 , BACKUP，优先级80
 virtual_router_id 3 , Vrrp instance 3 , BACKUP，优先级60
 #第二个节点ka2配置：
virtual_router_id 1 , Vrrp instance 1 , BACKUP，优先级60
 virtual_router_id 2 , Vrrp instance 2 , MASTER，优先级100
 virtual_router_id 3 , Vrrp instance 3 , BACKUP，优先级80
 #第三个节点ka3配置：
virtual_router_id 1 , Vrrp instance 1 , BACKUP，优先级80
 virtual_router_id 2 , Vrrp instance 2 , BACKUP，优先级60
 virtual_router_id 3 , Vrrp instance 3 , MASTER，优先级100
```

#### 7.4.8同步组

LVS NAT 模型VIP和DIP需要同步，需要同步组

```bash
vrrp_sync_group VG_1 {
 group {
    VI_1  
# name of vrrp_instance (below)
    VI_2  
# One for each moveable IP
   }
  }
 vrrp_instance VI_1 {
 eth0
 vip
  }
 vrrp_instance VI_2 {
 eth1
 dip
  }
```

### 7.5实现 IPVS 的高可用性

#### 7.5.1IPVS 相关配置

**1 虚拟服务器配置结构**

每一个虚拟服务器即一个IPVS集群

**2 Virtual Server （虚拟服务器）的定义格式**

```powershell
root@ubuntu24-13:~# cat /etc/keepalived/conf.d/cluster1.conf
vrrp_instance VI_1 {
    state MASTER
    interface ens37
    virtual_router_id 50
    priority 100
    unicast_src_ip 192.168.8.13
    unicast_peer {
        192.168.8.16
    }
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.0.0.100 dev ens33 label ens33:1
    }
    notify_master "/etc/keepalived/send_message_by_email.sh master"
    notify_backup "/etc/keepalived/send_message_by_email.sh backup"
    notify_fault "/etc/keepalived/send_message_by_email.sh fault"
}
virtual_server 10.0.0.100 80 {
    delay_loop 2               用于服务轮询的延迟计时器
    lb_algo rr
    lb_kind DR                  设定数据转发的模型
    protocol TCP
    real_server 10.0.0.14 80 {
        weight 1
        HTTP_GET {                   #健康监测
           url {
             path /testurl3/test.jsp
             digest 640205b7b0fc66c1ea91c463fac6334d
           }
           connect_timeout 3
           retry 3
           delay_before_retry 3
       }
    }
    real_server 10.0.0.17 80 {
        weight 3
    }
    sorry_server 备用真实主机，当所有RS失效后，开始启用该后备主机。
}
```

**3 虚拟服务器组**

将多个虚拟服务器定义成一个组，统一对外服务，如：http和https定义成一个虚拟服务器组

**4 虚拟服务器配置**

**5 应用层监测**

**6 TCP监测**

#### 7.5.2实战案例：实现单主的 LVS-DR 模式

#### 7.5.3实战案例：实现单主的 LVS-DR 模式，利用FWM绑定成多个服 务为一个集群服务

### 7.6基于 VRRP Script 实现其它应用的高可用性

keepalived利用 VRRP Script 技术，可以调用外部的辅助脚本进行资源监控，并根据监控的结果实现优 先动态调整，从而实现其它应用的高可用性功能

```powershell
root@ubuntu24-13:~# cat /etc/keepalived/conf.d/cluster1.conf
vrrp_script chk_keepalived {
   script "[ ! -f /tmp/keepalived.fail ]" # 如果不存在，则返回0，如果存在则返回非
0
   interval 1
   weight -30 # 优先级降低30
   fall 3
   rise 2
   timeout 2
}
vrrp_instance VI_1 {
    state MASTER
    interface ens37
    virtual_router_id 50
    priority 100
    unicast_src_ip 192.168.8.13
    unicast_peer {
        192.168.8.16
    }
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.0.0.100 dev ens33 label ens33:1
    }
    notify_master "/etc/keepalived/send_message_by_email.sh master"
    notify_backup "/etc/keepalived/send_message_by_email.sh backup"
    notify_fault "/etc/keepalived/send_message_by_email.sh fault"
    track_script {
        chk_keepalived
    }
}
...
注意：
  track_script 中使用的名称，一定要在 vrrp_script 中定义
 vrrp_script中script属性的脚本使用，应该使用标准的"/bin/bash 
/path/to/file"格式
 避免因为权限问题导致脚本无法执行，从而影响keepalived的正常使用
```



## 8.微服务

### 8.1微服务介绍

微服务特点 

功能单一职责: 微服务拆分粒度更小，每一个服务都对应唯一的业务能力，做到单一职责，避免重复业务开发 

访问面向服务:微服务对外暴露业务接口,通过接口实现服务的访问,而不能直接访问服务内的数据和功能 

独立自治: 团队独立、技术独立、数据独立、部署独立 

安全性: 服务调用需要实现隔离,容错,降级等安全保护,防止级联故障

![image-20250520205302657](./image-20250520205302657.png)

![image-20250520205335572](./image-20250520205335572.png)

Spring Cloud 进行了一些重要的更新，例如支持新的服务发现工具，如 Kubernetes 服务发现，更好地支持云原生应用的 构建和部署。

Spring Cloud Netflix  https://github.com/Netflix

![image-20250520205453147](./image-20250520205453147.png)

### 8.2zookeeper

#### 8.2.1ZooKeeper 介绍

ZooKeeper 是一个分布式服务框架，它主要是用来解决分布式应用中经常遇到的一些数据管理问题，如：**命名服务、状态同步、配置中心、 集群管理等**。

Zookeeper 一个最常用的使用场景就是用于担任服务生产者和服务消费者的注册中心(提供发布订阅服务)。 服务生产者将自己提供的服务注 册到Zookeeper中心，服务的消费者在进行服务调用的时候先到Zookeeper中查找服务，获取到服务生产者的详细信息之后，再去调用服务 生产者的内容与数据。在 Dubbo架构中 Zookeeper 就担任了注册中心这一角色。

官网:   https://zookeeper.apache.org/ 官方文档:  https://zookeeper.apache.org/doc/

![image-20250520210850306](./image-20250520210850306.png)

1. 生产者启动 
2. 生产者注册至zookeeper 
3. 消费者启动并订阅频道 
4. zookeeper 通知消费者事件 
5. 消费者调用生产者 
6. 监控中心负责统计和监控服务状态

#### 8.2.2ZooKeeper 安装

Zookeeper 支持多种安装方法 

包 二进制 容器 https://hub.docker.com/_/zookeeper

##### 1 ZooKeeper 单机部署

官方文档: https://zookeeper.apache.org/doc/r3.6.2/zookeeperStarted.html#sc_InstallingSingleMode

##### 一键安装 ZooKeeper 脚本

#### 8.2.3 ZooKeeper 集群部署

官方文档: https://zookeeper.apache.org/doc/r3.6.2/zookeeperAdmin.html#sc_zkMulitServerSetup

![image-20250520211656686](./image-20250520211656686.png)

集群中节点数越多，写性能越差，读性能越好

![image-20250520211815050](./image-20250520211815050.png)

![image-20250520212209342](./image-20250520212209342.png)

**ZooKeeper 集群特性**

整个集群中只要有超过集群数量一半的 zookeeper工作是正常的，那么整个集群对外就是可用的 假如有 2 台服务器做了一个 Zookeeper 集群，只要有任何一台故障或宕机，那么这个 ZooKeeper集群就不可用了，因为剩下的一台没有超 过集群一半的数量，但是假如有三台zookeeper 组成一个集群， 那么损坏一台就还剩两台，大于 3台的一半，所以损坏一台还是可以正常运 行的，但是再损坏一台就只剩一台集群就不可用了。那么要是 4 台组成一个zookeeper集群，损坏一台集群肯定是正常的，那么损坏两台就 还剩两台，那么2台不大于集群数量的一半，所以 3 台的 zookeeper 集群和 4 台的 zookeeper集群损坏两台的结果都是集群不可用，以此类 推 5 台和 6 台以及 7 台和 8台都是同理

#### 8.2.4图形化客户端 ZooInspector

github链接 https://github.com/zzhang5/zooinspector 

https://gitee.com/lbtooth/zooinspector.git

### 8.3kafka

\#阿里云消息队列 https://www.aliyun.com/product/ons?spm=5176.234368.h2v3icoap.427.2620db25lcHi1Q&aly_as=Tz_Lue_o

#### 8.3.1消息队列简介

在分布式场景中，相对于大量的用户请求来说，内部的功能主机之间、功能模块之间等，数据传递的数据量是无法想象的，因为一个用户请 求，会涉及到各种内部的业务逻辑跳转等操作。那么，在大量用户的业务场景中，如何保证所有的内部业务逻辑请求都处于稳定而且快捷的 数据传递呢? 消息队列(Message Queue)技术可以满足此需求

![image-20250520213427275](./image-20250520213427275.png)

**消息队列主要有以下应用场景**

![image-20250520213731914](./image-20250520213731914.png)

#### 8.3.2kafka角色和流程

![image-20250520214601089](./image-20250520214601089.png)

![image-20250716114604792](image-20250716114604792.png)

**Producer**：Producer即生产者，消息的产生者，是消息的入口。负责发布消息到Kafka broker。

**Consumer**：消费者，用于消费消息，即处理消息

**Broker**：Broker是kafka实例，每个服务器上可以有一个或多个kafka的实例，假设每个broker对应一台服务器。每个kafka集群内的broker 都有一个不重复的编号，如: broker-0、broker-1等……

**Controller**：是整个 Kafka 集群的管理者角色，任何集群范围内的状态变更都需要通过 Controller 进行，在整个集群中是个单点的服务，可 以通过选举协议进行故障转移，负责集群范围内的一些关键操作：主题的新建和删除，主题分区的新建、重新分配，Broker 的加入、退出， 触发分区 Leader 选举等，每个 Broker 里都有一个 Controller 实例，多个 Broker 的集群同时最多只有一个 Controller 可以对外提供集群管 理服务，Controller 可以在 Broker 之间进行故障转移，Kafka 集群管理的工作主要是由 Controller 来完成的，而 Controller 又通过监听  Zookeeper 节点的变动来进行监听集群变化事件，Controller 进行集群管理需要保存集群元数据，监听集群状态变化情况并进行处理，以及 处理集群中修改集群元数据的请求，这些主要都是利用 Zookeeper 来实现

**Topic** ：消息的主题，可以理解为消息的分类，一个Topic相当于数据库中的一张表,一条消息相当于关系数据库的一条记录，或者一个Topic 相当于Redis中列表数据类型的一个Key，一条消息即为列表中的一个元素。kafka的数据就保存在topic。在每个broker上都可以创建多个 topic。

**Consumer group**: 每个consumer 属于一个特定的consumer group（可为每个consumer 指定 group name，若不指定 group name 则 属于默认的group），同一topic的一条消息只能被同一个consumer group 内的一个consumer 消费，类似于一对一的单播机制，但多个 consumer group 可同时消费这一消息，类似于一对多的多播机制

**Partition** ：是物理上的概念，每个 topic 分割为一个或多个partition，即一个topic切分为多份, 当创建 topic 时可指定 partition 数量， partition的表现形式就是一个一个的文件夹,该文件夹下存储该partition的数据和索引文件，分区的作用还可以实现负载均衡，提高kafka的 吞吐量。同一个topic在不同的分区的数据是不重复的,一般Partition数不要超过节点数，注意同一个partition数据是有顺序的，但不同的 partition则是无序的。

**Replication**: 同样数据的副本，包括leader和follower的副本数,基本于数据安全,建议至少2个,是Kafka的高可靠性的保障，和ES的副本有所 不同，Kafka中的副(leader+follower）数包括主分片数,而ES中的副本数(follower)不包括主分片数

##### Kafka 工作机制

![image-20250520214957732](./image-20250520214957732.png)

![image-20250520215151588](./image-20250520215151588.png)

#### 8.3.3Kafka 部署

kafka下载链接 http://kafka.apache.org/downloads

##### 单机部署

#### 8.3.4消息积压

![image-20250520220759711](./image-20250520220759711.png)

#### 8.3.5基于Web的Kafka集群监控系统 kafka-eagle

Kafka eagle（kafka鹰） 是一款由国内公司开源的Kafka集群监控系统，可以用来监视kafka集群的broker状态、Topic信息、IO、内存、 consumer线程、偏移量等信息，并进行可视化图表展示。独特的KQL还可以通过SQL在线查询kafka中的数据。

官方地址 http://www.kafka-eagle.org/ 

https://github.com/smartloli/kafka-eagle-bin 

https://www.cnblogs.com/smartloli/

Kafka 常用监控指标

### 8.4Dubbo

```bash
阿里云微服务
https://promotion.aliyun.com/ntms/act/edasdubbo.html
 Dubbo 官网
https://dubbo.apache.org/zh/
 Dubbo 架构
https://dubbo.apache.org/zh/docs/v2.7/user/preface/architecture/
 Dubbo 运维
https://dubbo.apache.org/zh/docs/v2.7/admin/
 Dubbo 简介
https://help.aliyun.com/document_detail/99299.html
```

![image-20250520221225417](./image-20250520221225417.png)

1. 服务容器负责启动，加载，运行服务提供者。
2. 服务提供者在启动时，向注册中心注册自己提供的服务。
3. 服务消费者在启动时，向注册中心订阅自己所需的服务。
4. 注册中心返回服务提供者地址列表给消费者，如果有变更，注册中心将基于长连接推送变更数据给消费者。
5. 服务消费者，从提供者地址列表中，基于软负载均衡算法，选一台提供者进行调用，如果调用失败，再选另一台调用。
6. 服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心。

![image-20250520221315771](./image-20250520221315771.png)

![image-20250520221419581](./image-20250520221419581.png)

##### **实战案例：实现 Dubbo 微服务架构(新项目)**

### 8.5Nacos

Spring Cloud Alibaba  https://github.com/alibaba/spring-cloud-alibaba/blob/2022.x/README-zh.md

![image-20250521181246091](./image-20250521181246091.png)

##### 8.5.1 Nacos 是核心功能

https://nacos.io/

https://github.com/alibaba/nacos

Nacos 是阿里巴巴开源的一个基于JAVA语言的更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。

![image-20250521181450935](./image-20250521181450935.png)

##### 8.5.2Nacos 部署

Nacos 部署说明  https://nacos.io/zh-cn/docs/v2/quickstart/quick-start.html

![image-20250521181949670](./image-20250521181949670.png)

##### 8.5.3Nacos 实战案例

### 8.6Sentinel

#### 8.6.1Sentinel 介绍和工作机制

**微服务流量治理组件介绍**

随着微服务的流行，服务和服务之间的调用导致服务的稳定性问题变得越来越重要。 雪崩问题: 微服务调用链路中的某个服务故障，引起整个链路中的所有微服务都不可用，即雪崩。

解决雪崩问题的常见方式有四种: 

超时处理:设定超时时间，请求超过一定时间没有响应就返回错误信息，不会无休止等待 

流量控制:限制业务访问的QPS,避免服务因流量的突增而故障。 

熔断降级:由断路器统计业务执行的异常比例，如果超出阈值则会熔断该业务,拦截访问该业务的一切请求。 

舱壁模式:限定每个业务能使用的线程数，避免耗尽整个tomcat的资源， 因此也叫线程隔离。

```bash
https://sentinelguard.io/zh-cn/
 https://github.com/alibaba/spring-cloud-alibaba/wiki/Sentinel
 https://github.com/alibaba/Sentinel/
 https://github.com/sentinel-group
 https://github.com/alibaba/sentinel-golang
```

![image-20250521182431604](./image-20250521182431604.png)

#### 8.6.2 Sentinel 的构成

Sentinel 的构成可以分为两个部分: 核心库（Java 客户端）： 开发人员通过JAVA调用，不依赖任何框架/库，能够运行于 Java 8 及以上的版本的运行时环境，同时对 Dubbo / Spring Cloud 等框架 也有较好的支持（见  主流框架适配）。 **控制台（Dashboard）： 可以由运维部署，Dashboard 主要负责管理推送规则、监控、管理机器信息等。**

#### 8.6.3Sentinel 控制台

Sentinel 提供一个轻量级的开源控制台，它提供机器发现以及健康情况管理、监控（单机和集群），规则管理和推送的功能。 

Sentinel 控制台包含如下功能: 

查看机器列表以及健康情况：收集 Sentinel 客户端发送的心跳包，用于判断机器是否在线。 

监控 (单机和集群聚合)：通过 Sentinel 客户端暴露的监控 API，定期拉取并且聚合应用监控信息，最终可以实现秒级的实时监控。 

流量控制 

降级控制 

规则管理和推送：统一管理推送规则。 

鉴权：生产环境中鉴权非常重要。这里每个开发者需要根据自己的实际情况进行定制。

##### 部署和启动控制台

**二进制安装Sentinel dashboard脚本**

### 8.7Spring Cloud Gateway

![image-20250521183137677](./image-20250521183137677.png)

![image-20250521183310435](./image-20250521183310435.png)

### 8.8consul
