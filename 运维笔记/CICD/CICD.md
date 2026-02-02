[TOC]

# 1.devops简介

敏捷开发：

迭代开发，增量开发

优势 

尽早交付,加快资金回笼 

降级风险,及时了解市场需求，及时获取问题反馈 

提高效率,阶段性功能拆分及快速质量反馈

**什么是 DevOps**

DevOps是一组过程、方法与系统的统称，用于促进开发、技术运营和质量保障（QA）部门之间的沟 通、协作与整合。 

DevOps 是针对开发人员、运维人员和测试人员的一种工作理念，是软件在应用开发、代码部署和质量 测试等整条生命周期中协作和沟通的最佳实践 

DevOps 强调整个组织的所有相关部门的紧密合作以及交付和基础设施变更的自动化、从而实现持续集 成、持续部署和持续交付的目标

**持续集成、持续交付和持续部署 CICD**

持续集成（Continuous Integration）、持续交付（Continuous  Delivery） 、持续部署（Continuous Deployment）

集成指将多位开发者的开发代码提交后,合并集成在一起,存放在代码库的过程,并且后续还会不断的迭代 更新代码

持续交付的目标是拥有一个可随 时部署到生产环境的代码库。

持续部署可以自动将应用发布到生产环境。

**蓝绿部署 Blue-green Deployments**

蓝绿部署指的是不停止老版本代码(不影响上一个版本访问)，而是在另外一套环境部署新版本然后进行测 试，测试通过后将用户流量切到新版本

**金丝雀(灰度)发布 Canary Deployment**

金丝雀发布也叫灰度发布，是指在黑与白之间，能够平滑过渡的一种发布方式，灰度发布是增量发布 （例如：2%、25%、75%、100%）进行更新)的一种类型，灰度发布是在原有版本可用的情况下，同时 部署一个新版本应用作为“金丝雀”(小白鼠)，测试新版本的性能和表现，以保障整体系统稳定的情况下， 尽早发现、调整问题。

**滚动发布(更新)**



# 2.版本管理工具git和gitlab

DevOps 涉及的四大相关平台 项目管理：

如：Jira,禅道 代码托管

如：Gitlab,SVN 持续交付

如：Jenkins,Gitlab 运维平台

如：腾讯蓝鲸,Spug等

![image-20250525232329590](./image-20250525232329590.png)

![image-20250525232437427](./image-20250525232437427.png)

```bash
git chechout -b feature #from develop，完成开发和特性测试
git checkout develop
 git merge feature
 git branch --delete feature
 git checkout -b release # from develop，完成测试、bug修复和发布
git checkout develop
 git merge release   
#将release合并至develop
 git checkout master
 git merge release #将release合并至master
 git branch --delete release #删除releae分支
```

## 2.1私有仓库gitlab

![image-20250525232946197](./image-20250525232946197.png)

### 2.1.1GitLab 安装

Gitlab 服务的安装文档： https://docs.gitlab.com/ce/install/

安装的最新版

```powershell
#!/bin/bash
set -e

# 配置访问域名或IP
DOMAIN="gitlab.local"
EXTERNAL_URL="http://$DOMAIN"

echo "安装 GitLab CE，访问地址：$EXTERNAL_URL"

# 添加 GitLab 官方仓库
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash

# 安装最新的 GitLab CE
EXTERNAL_URL="$EXTERNAL_URL" dnf install -y gitlab-ce

# 初始化配置并启动 GitLab
gitlab-ctl reconfigure

echo ""
echo "✅ GitLab CE 安装完成！"
echo "🔗 访问地址： $EXTERNAL_URL"
echo "请首次访问设置 root 密码"

```

安装方法说明 https://docs.gitlab.com/ee/install/install_methods.html

Gitlab硬件和软件的环境要求：  https://docs.gitlab.com/ce/install/requirements.html 

硬件配置要求较高： 测试环境：内存4G以上 生产环境：建议CPU2C以上，内存8G以上，磁盘10G以上配置，和用户数有关

**一键安装gitlab脚本**

### 2.1.2GitLab 基本配置

首次登录 GitLab Web 界面修改密码  新版gitlab密码初始化官方帮助链接 https://docs.gitlab.com/omnibus/installation/index.html

浏览器访问 http://gitlab服务器IP/

```bash
#如果没有在配置文件中对密码做初始化设置,可以从以下文件找到初始密码
[root@ubuntu1804 ~]#cat /etc/gitlab/initial_root_password
```

### 2.1.3GitLab 项目管理

#### 保护分支

![image-20250526022210252](./image-20250526022210252.png)

### 2.1.4GitLab 的数据备份和恢复

https://docs.gitlab.com/ee/raketasks/backup_restore.html

#### 备份

备份相关配置文件  

```bash
/etc/gitlab/gitlab.rb 

/etc/gitlab/gitlab-secrets.json #双因子验证等使用此文件

备份配置文件命令
gitlab-ctl backup-etc --backup-path <DIRECTORY>
```

```bash
#GitLab 12.2之后版本
gitlab-backup create
 #GitLab 12.1之前版本
gitlab-rake gitlab:backup:create

#默认备份保存在下面目录
[root@ubuntu1804 ~]#ll /var/opt/gitlab/backups/
```

![image-20250526050040578](./image-20250526050040578.png)

#### 执行恢复

```bash
#恢复前先停止两个服务
[root@ubuntu1804 ~]#gitlab-ctl stop puma
 [root@ubuntu1804 ~]#gitlab-ctl stop sidekiq
 #恢复时指定备份文件的时间部分，不需要指定文件的全名
[root@ubuntu1804 ~]#gitlab-backup restore BACKUP=备份文件名的时间部分_Gitlab版本

[root@ubuntu1804 ~]#gitlab-ctl reconfigure
 [root@ubuntu1804 ~]#gitlab-ctl restart
 #后续检查可选做
[root@ubuntu1804 ~]#gitlab-rake gitlab:check SANITIZE=true
 #In GitLab 13.1 and later, check database values can be decrypted especially if 
/etc/gitlab/gitlab-secrets.json was restored, or if a different server is the 
target for the restore.
 [root@ubuntu1804 ~]#gitlab-rake gitlab:doctor:secrets
```

旧版恢复方法 

```bash
#恢复前先停止两个服务
[root@ubuntu1804 ~]#gitlab-ctl stop unicorn
 [root@ubuntu1804 ~]#gitlab-ctl stop sidekiq 
#恢复时指定备份文件的时间部分，不需要指定文件的全名
[root@ubuntu1804 ~]# gitlab-rake gitlab:backup:restore BACKUP=备份文件名的时间部分
```

确保还原完成

### 2.1.5GitLab 汉化

![image-20250526052941272](./image-20250526052941272.png)

### 2.1.6GitLab 迁移和升级

**迁移流程** 

在原GitLab主机上备份配置文件和数据 

在目标主机上安装相同的版本的GitLab软件 

还原配置和数据 

**本质上就是备份和恢复的过程**

![image-20250526053608960](./image-20250526053608960.png)

### 2.1.7实现 Https

![image-20250526053656547](./image-20250526053656547.png)

# 3.jenkins

官方文档 https://www.jenkins.io/zh/doc/

 Jenkins 是基于 Java 开发的一种开源的CI（Continuous integration持续集成）&CD (Continuous  Delivery持续交付，Continuous Deployment持续部署)工具

jenkins 版本 

https://www.jenkins.io/download/ 

https://www.jenkins.io/zh/download/ 

https://mirrors.tuna.tsinghua.edu.cn/jenkins/

## 3.1基础配置

### 3.1.1插件管理

将升级站点URL替换成下面国内镜像地址

![image-20250526181535925](./image-20250526181535925.png)

![image-20250526181549334](./image-20250526181549334.png)

### 3.1.2修改 Jenkins 的启动用户为 root(可选)

默认Jenkins以jenkins的用户身份运行,会导致权限受限,可以修改service文件设为root身份运行解决此问 题 

```bash
#基于 Ubuntu安装修改下面文件
[root@jenkins ~]#vim /usr/lib/systemd/system/jenkins.service
 #User=jenkins	
 #Group=jenkins
 User=root
 Group=root
 [root@jenkins ~]#systemctl daemon-reload 
[root@jenkins ~]#systemctl restart jenkins.service 
#基于RHEL系统安装修改下面文件
[root@jenkins ~]#vim /etc/sysconfig/jenkins
 #JENKINS_USER="jenkins"
 JENKINS_USER="root"
```

### 3.1.3 Jenkins 优化配置

Jenkins 服务器做为一个CICD工具,后续会经常使用 ssh 协议连接远程主机,为方便连接,建议修改自动信 任远程主机,避免首次连接的人为输入yes的确认过程

方法1: 系统管理 --  全局安全配置 

注意:需要安装Git或者Gitlab插件才能配置

![image-20250526183538962](./image-20250526183538962.png)

方法2:  在 Jenkins 服务器修改 ssh的客户端配置文件 

```bash
[root@jenkins ~]#vi /etc/ssh/ssh_config 
#  StrictHostKeyChecking ask #修改此行如下面   
StrictHostKeyChecking no #修改客户端配置无需重启ssh服务
```

**性能优化**

默认只能并行2个任务,建议根据CPU核心数,将执行者数量修改为CPU的核数

![image-20250526184715100](./image-20250526184715100.png)

### 3.1.4Jenkins 的备份还原

Jenkins的相关数据都是放在主目录中, 将主目录备份即可实现Jenkins的备份,必要时用于还原 另外如果有相关脚本等,也需要进行备份

![image-20250526185820746](./image-20250526185820746.png)

![image-20250526185828420](./image-20250526185828420.png)

### 3.1.5找回忘记的密码

刚开始安装 Jenkins，没有修改过密码 直接在initialAdminPassword文件中查看密码即可 

```bash
[root@ubuntu2204-100 ~]#cat /var/lib/jenkins/secrets/initialAdminPassword c72aae9f6418442b979b10de4c8d275
```

方法2

![image-20250526190039891](./image-20250526190039891.png)

![image-20250526190109404](./image-20250526190109404.png)

![image-20250526190322450](./image-20250526190322450.png)

![image-20250526190342849](./image-20250526190342849.png)

## 3.2Jenkins 实现 CICD

![image-20250526191032464](./image-20250526191032464.png)

![image-20250526191044644](./image-20250526191044644.png)

![image-20250526191416092](./image-20250526191416092.png)

### 3.2.1创建 Freestyle 风格的任务 Job

构建支持变量 http://jenkins-server:8080/env-vars.html/

![image-20250526191718696](./image-20250526191718696.png)

**实现一个简单的 Freestyle 任务**

![image-20250526192329512](./image-20250526192329512.png)

![image-20250526192337560](./image-20250526192337560.png)

#### 环境变量与自定义环境变量

![image-20250526192637064](./image-20250526192637064.png)

任务中的自定义的变量 > Jenkins 的自定义环境量 > Jenkins 内置的环境变量

![image-20250526192658050](./image-20250526192658050.png)

### 3.2.2 Jenkins 结合 GitLab 实现代码下载

https://docs.gitlab.com/ee/integration/jenkins.html

![image-20250526193303569](./image-20250526193303569.png)

#### Jenkins 服务器创建访问GitLab的凭据

![image-20250526193424319](./image-20250526193424319.png)

![image-20250526193332449](./image-20250526193332449.png)

![image-20250526193537906](./image-20250526193537906.png)

![image-20250526193603021](./image-20250526193603021.png)

![image-20250526193938908](./image-20250526193938908.png)

![image-20250526193945154](./image-20250526193945154.png)

### 3.2.3配置 Jenkins 结合 GitLab 实现自动化前端项目的部署 和回滚

1. Jenkins 创建任务
2. 配置 Git 项目地址和凭证，先在gitlab上确认git地址和分支名称

![image-20250526194450368](./image-20250526194450368.png)

3.准备脚本并加入构建任务

```bash
HOST_LIST="
10.0.0.202
10.0.0.203
"
APP=wheel
APP_PATH=/var/www/html
DATA_PATH=/opt
DATE=`date +%F_%H-%M-%S`
deploy () {
    for i in ${HOST_LIST};do
        ssh root@$i "rm -f  ${APP_PATH} && mkdir -pv 
${DATA_PATH}/${APP}-${DATE}"
       scp -r * root@$i:${DATA_PATH}/${APP}-${DATE}
        ssh root@$i "ln -sv ${DATA_PATH}/${APP}-${DATE} ${APP_PATH}"
    done
}
rollback() {
    for i in ${HOST_LIST};do
        CURRENT_VERISION=$(ssh root@$i "readlink $APP_PATH")
        CURRENT_VERISION=$(basename ${CURRENT_VERISION})
        echo ${CURRENT_VERISION}
        PRE_VERSION=$(ssh root@$i "ls -1 ${DATA_PATH} | grep -B1 
${CURRENT_VERISION}|head -n1 ")
        echo $PRE_VERSION
        ssh root@$i "rm -f  ${APP_PATH}&& ln -sv ${DATA_PATH}/${PRE_VERSION}
${APP_PATH}"
    done
}
case $1 in
deploy)
   deploy
   ;;
rollback)
   rollback
   ;;
*)
    exit
   ;;
esac
```

4.在Jenkins中引用脚本

![image-20250526194848348](./image-20250526194848348.png)

5.**立即构建**

![image-20250526194928935](./image-20250526194928935.png)

6.**服务器验证数据**

7.**将代码部署至后端** **Web** **服务器**

8.**访问** **Web** **服务**

9.**修改代码再上传重新构建**

```bash
git clone git@gitlab.wang.org:dev/wheel_of_fortune.git
cd wheel_of_fortune/
vi index.html 
git add .;git commit -m '500w';git push
```

10.新建任务，实现回滚功能

![image-20250526195152142](./image-20250526195152142.png)

### 3.2.4参数化构建

#### 3.2.4.1字符参数实现实现不同分支的部署

![image-20250526202907431](./image-20250526202907431.png)

#### 3.2.4.2选项参数实现实现不同分支的部署

![image-20250526203401316](./image-20250526203401316.png)

![image-20250526203413039](./image-20250526203413039.png)

#### 3.2.4.3选项参数实现不同分支的部署和回滚

![image-20250526203720004](./image-20250526203720004.png)

### 3.2.5利用 Git Parameter 插件实现拉取指定版本

#### 利用 Git Parameter 插件实现拉取指定 Tag

![image-20250526203937066](./image-20250526203937066.png)

![image-20250526204336638](./image-20250526204336638.png)

#### 利用 Git Parameter 插件实现拉取指定 Commit_ID

![image-20250526204454211](./image-20250526204454211.png)

![image-20250526204512023](./image-20250526204512023.png)

### 3.2.6实现 Java 应用源码编译并部署

#### 基于自由风格构建基于 Spring Boot 的 JAR 包 JAVA 项目

![image-20250526204634309](./image-20250526204634309.png)

##### Jenkins 服务器上安装 maven 和配置镜像加速

方法1:系统配置文件

![image-20250526210344495](./image-20250526210344495.png)

方法2：通过Config File Provider插件完成

注意：此方法只支持maven风格的任务，不支持命令行的mvn命令

##### Jenkins 全局工具配置 JDK 和 Maven

![image-20250526211249637](./image-20250526211249637.png)

方法1: 手动安装 maven

方法2：自动安装 Maven

![image-20250526211401683](./image-20250526211401683.png)

#### 基于 Maven 风格的任务构建基于WAR包运行 Tomcat服务器 JAVA 项目

1 Gitlab仓库中准备 Java 代码

2 安装 tomcat 服务器和配置

3 Jenkins 安装 Maven 和 Tomcat 两个插件

4 Jenkins 服务器上安装 maven 和配置镜像加速

5 Jenkins 全局工具配置 JDK (可选)和 Maven(必选)

6 创建 Tomcat 的全局凭据

7 创建 Maven 风格的任务

注意: 因Maven 风格的任务存在安全风险, Jenkins官方已经不再建议使用, 使用自由风格的项目或者 Pipeline作业替代

### 3.2.7实现 Golang 应用源码编译并部署

### 3.2.8集成 Ansible 的任务构建

官方参考 https://plugins.jenkins.io/ansible/

1 安装 Ansible 环境

2 安装 Ansible 插件

3 使用 Ansible Ad-Hoc 实现任务

![image-20250526212030335](./image-20250526212030335.png)

#### 使用 Ansible Playbook 基于参数化实现任务测试和生产多套 不同环境的部署

1 准备Playbook文件

2 准备两个不同环境的所有主机清单文件

3 创建参数化任务

![image-20250526212207600](./image-20250526212207600.png)

### 3.2.9构建后通知

#### 邮件通知

2 mailer 插件实现邮件告警

配置 Jenkins管理员邮箱

在 Pipeline 中添加邮件通知

#### 钉钉通知

插件说明 https://jenkinsci.github.io/dingtalk-plugin/ https://jenkinsci.github.io/dingtalk-plugin/guide/getting-started.html

![image-20250526213155130](./image-20250526213155130.png)

#### Pipeline 实现钉钉通知

![image-20250526213305298](./image-20250526213305298.png)

#### 微信通知

### 3.2.10自动化构建

周期性构建 

Webhook 触发构建

#### 3.2.10.1定时和 SCM 构建

![image-20250526213636602](./image-20250526213636602.png)

![image-20250526213711389](./image-20250526213711389.png)

![image-20250526213733138](./image-20250526213733138.png)

#### 3.2.10.2构建 Webhook 触发器

![image-20250526213911401](./image-20250526213911401.png)

### 3.2.11构建前后多个项目关联自动触发任务执行

### 3.2.12Blue Ocean 插件实现可视化

### 3.2.13 实现容器化的 Docker 任务

1 在harbor.wang.org主机上安装Harbor

2 在目标主机安装 Docker，并且打开远程连接端口，并且信任harbor

3 在Gitlab 准备项目

4 在 Jenkins 创建任务

5.编写脚本

![image-20250526223754241](./image-20250526223754241.png)

#### 基于 Docker 插件实现自由风格任务实现 Docker 镜像 制作

1 准备源码项目和对应的Dockerfile

2 安装插件 docker-build-step

3 在Jenkins 安装Docker并配置 Docker 插件

![image-20250526223945591](./image-20250526223945591.png)

```bash
[root@ubuntu2204 ~]#usermod -aG docker jenkins
[root@ubuntu2204 ~]#id jenkins
```

4 在 Jenkins 创建连接 Harbor 的凭证

5 创建任务

![image-20250526224132352](./image-20250526224132352.png)

### 3.2.14集成 Kubernetes

![image-20250526224648004](./image-20250526224648004.png)

### 3.2.15推送构建状态信息至GitLab

## 3.3jenkins分布式

![image-20250526225758699](./image-20250526225758699.png)

Java程序分配至Slave1,Go程序的编译分配给Slave2,Nodejs程序分配给Slave3

采用 master/agent 架构，因而其节点可划分主节点(master)和代理节点(agent)两种类型,，代理节点也 被称为从节点(slave)

**主节点负责提供UI、处理HTTP请求及管理构建环境等，而代理节点则主要负责执行构建任务**

![image-20250526225933920](./image-20250526225933920.png)

![image-20250526230245179](./image-20250526230245179.png)

### 实战案例: 基于 SSH 协议实现 Jenkins 分布式

### 实战案例: 基于docker-compose 通过SSH 实现 Jenkins 分布 式

### 案例：Kubernets集群实现Jenkins分布式构建

## 3.4jenkins pipeline

所谓的 Pipeline 流水线，其实就是将之前的一个任务或者一个脚本就做完的工作，用 Pipeline 语法划分 为多个子任务然后分别执行，两者实现的最终效果是一样的，但是由于原始任务划分为多个子任务之 后，以流水线的方式来执行，那么就可以随时查看任意子任务的执行效果，即使在某个阶段出现问题， 我们也可以随时直接定位问题的发生点，大大提高项目的效率,即模块化完成复杂任务的思想体现

![image-20250526230946405](./image-20250526230946405.png)

```bash
官方文档
https://www.jenkins.io/zh/doc/book/pipeline/syntax/
 http://www.jenkins.io/doc/book/pipeline/syntax/
 http://www.jenkins.io/doc/pipeline/steps/
 #支持docker
 https://www.jenkins.io/doc/book/pipeline/docker/
```

![image-20250526231308727](./image-20250526231308727.png)

### 实现一个简单 Pipeline Job

1 安装 Pipeline 插件

![image-20250526231635327](./image-20250526231635327.png)

![image-20250526231648031](./image-20250526231648031.png)

2 创建 Pipeline Job

![image-20250526231715842](./image-20250526231715842.png)

3 测试简单 Pipeline Job 运行

![image-20250526231749136](./image-20250526231749136.png)

![image-20250526231755056](./image-20250526231755056.png)

![image-20250526231808369](./image-20250526231808369.png)

### 自动生成拉取代码的 Pipeline 脚本

![image-20250526231908374](./image-20250526231908374.png)

### 回放

![image-20250526232005939](./image-20250526232005939.png)



### 实战案例: 脚本式 Pipeline

![image-20250526232049737](./image-20250526232049737.png)

![image-20250526232145885](./image-20250526232145885.png)

指定node节点

![image-20250526233427815](./image-20250526233427815.png)

### 实战案例: 声明式 Pipeline

![image-20250527032802540](./image-20250527032802540.png)

![image-20250527032844937](./image-20250527032844937.png)

![image-20250527033109547](./image-20250527033109547.png)

![image-20250527033125731](./image-20250527033125731.png)

## 3.5Jenkins 视图

视图可用于归档job进行分组显示，比如将一个业务的视图放在一个视图显示，安装完成插件之后将会有 一个+号用于创建视图，支持三种视图，其中列表视图使用较多。

### 列表视图

![image-20250527115956354](./image-20250527115956354.png)

1 创建新的视图

2 定义视图名称

3 选择视图包含的任务

![image-20250527120026387](./image-20250527120026387.png)

### 我的视图

我的视图会显示当前账户有权限访问的job，因此需要提前划分好权限

![image-20250527120112601](./image-20250527120112601.png)

### Pipeline 视图

Pipeline 视图可以显示任务之间的上下游关系，而非Pipeline风格的任务

## 3.6Jenkins 权限管理

默认jenkins用户可以执行所有操作和管理所有job 为了更好的分层控制，可以实现基于角色的权限管理，先创建角色和用户，给角色授权，然后把用户管 理到角色。

![image-20250527120824782](./image-20250527120824782.png)

![image-20250527120847711](./image-20250527120847711.png)

### 3.6.1安装角色权限相关的插件

搜索Role-based Authorization Strategy可以找到下面插件

![image-20250527120946069](./image-20250527120946069.png)

![image-20250527121119016](./image-20250527121119016.png)

![image-20250527121159018](./image-20250527121159018.png)

项目角色

## 3.7代码质量检测 SonarQube

### 3.7.1代码测试工具 SonarQube 简介

官方网站： http://www.sonarqube.org/  

下载地址： https://www.sonarqube.org/downloads/

![image-20250527183829226](./image-20250527183829226.png)

![image-20250527183952879](./image-20250527183952879.png)

Sonar有两种使用方式：插件和客户端

Sonar的插件名称为 sonarlint,实现支持多种开发工具的IDE的插件安装

官方LTS版本说明 https://www.sonarqube.org/downloads/lts/

### 3.7.2系统内核优化  

https://docs.sonarqube.org/latest/requirements/prerequisites-and-overview/

```bash
#mv.max_map_count 用于限制一个进程可以拥有的VMA(虚拟内存区域)的数量
sysctl -w vm.max_map_count=524288
 #设置系统最大打开的文件描述符数
sysctl -w fs.file-max=131072
 #每个用户可以打开的文件描述符数
ulimit -n 131072
 #每个用户可以打开的线程数
ulimit -u 8192
```

```bash
[root@SonarQube-Server ~]#vim /etc/sysctl.conf
 vm.max_map_count=262144  #此项必须修改,否则无法启动
fs.file-max=65536        
#此项可不改,默认值满足要求
#此文件可不改,可选
[root@SonarQube-Server ~]# vim /etc/security/limits.conf
 sonarqube  -  nofile  65536
 sonarqube  -  nproc  4096
root       -  nofile  65536  
root        -  nproc  4

 #如果以systemd 运行SonarQube,需要在service文件配置
[servcie]
 .....
 LimitNOFILE=65536
 LimitNPROC=4096
 ......
```

### 3.7.3环境依赖说明

**数据库**

SonarQube 7.9 以上版本的数据库要求  https://docs.sonarqube.org/7.9/requirements/requirements/ 

注意：SonarQube 7.9 不再支持MySQL，可以选择安装 PostgreSQL

SonarQube 6.7 的数据库要求  https://docs.sonarqube.org/6.7/Requirements.html 

SonarQube 6.7 数据库要使用MySQL 5.6版本，不支持MySQL 5.5的版本

**java**

SonarQube 9.9 以上版本的 java 环境要求  

https://docs.sonarsource.com/sonarqube/latest/requirements/prerequisites-and-overview/

SonarQube 7.9 以上版本不再支持 java 11    安装 openjdk-17-jdk

SonarQube 7.9 以上版本不再支持 java 8      安装 openjdk-11-jdk

 

### 3.7.4安装 SonarQube 服务器

1 安装和配置 PostgreSQL 数据库(或mysql)

2 2 下载 SonarQube 和修改配置文件

设置 SonarQube 连接数据库

3 启动 SonarQube

注意:SonarQube 需要调用 Elasticsearch，而且默认需要使用普通用户启动，如果以root启动会报错

4 创建 service 文件

5 登录到 Web 界面

http://SonarQube服务器IP:9000

#### 通过 Docker compose 部署 SonarQube

### 3.7.5管理 SonarQube 服务器

```bash
#初始此目录没有插件文件 
[root@SonarQube-Server ~]#ll /usr/local/sonarqube/extensions/plugins/
```

#### 安装中文语言插件

#### 安装其他插件  

Sonarquebe对代码的扫描都基于插件实现，因此要安装扫描的各种开发语言的插件

默认已安装 Java、Python、Go，Php，javaScript，Html 等语言对应的插件

插件可以在github上找到最新版本 https://github.com/SonarSource

### 3.7.6权限管理

![image-20250527185458077](./image-20250527185458077.png)

### 3.7.7部署代码扫描器 sonar-scanner

官方文档： https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/

**sonar-scanner 安装方法2：在 Jenkins 全局tools中自动安装**

![image-20250527190006114](./image-20250527190006114.png)

![image-20250527190041239](./image-20250527190041239.png)

**准备测试代码和配置文件**

sonar-scanner 扫描的代码需要提前在项目的根目录下准备名称为sonar-project.properties的文件，内 容如下

![image-20250527190934275](./image-20250527190934275.png)

#### 在源代码目录执行扫描

直接执行/usr/local/sonar-scanner/bin/sonar scanner

#### Maven实现代码检测

![image-20250527191759655](./image-20250527191759655.png)

#### SonarQube Web 界面验证扫描结果

### 3.7.8Jenkins 和 SonarQube 集成实现代码扫描

![image-20250527191405354](./image-20250527191405354.png)

Jenkins借助于SonarQube Scanner插件将SonarQube提供的代码质量检查能力集成到pipeline上,从而 确保质量阈检查失败时，能够避免继续进行后续的操作，例如发布等

#### SonarQube 质量阈

代码质量扫描结果可满足这组条件时,项目才会被标记为“passed”

![image-20250527191458995](./image-20250527191458995.png)

#### Jenkins 通过 Shell 实现 sonar scanner 功能

#### Jenkins 安装 SonarQube 插件实现代码扫描

1.在 Jenkins上安装SonarQube插件

2.配置Jenkins对接到SonarQube Server

3.配置Jenkins的全局工具sonar-scanner

4.在SonarQube上添加回调Jenkins的Webhook

5.在Jenkins项目上调用sonar-scanner进行代码质量扫描

6.通过SonarQube确认扫描结果的评估

注意，达成部署目的的方式都可以添加这一层

### 3.7.9案例1: Pipeline 集成 SonarQube 实现代码检测通知 Jenkins

1 在 SonarQube 添加 Jenkins 的回调接口

2.准备项目的 Jenkinsfile 文件

在项目所在的目录中准备Jenkinsfile文件

注意: 之后需要git commit 此文件

![image-20250527192733136](./image-20250527192733136.png)

### 3.7.10案例2: 基于 PipeLine 实现 JAVA项目集成 SonarQube 代码检测通知 Jenkins(推荐操作）

## 3.8安装 Harbor 并配置 Jenkins 连接 Harbor

