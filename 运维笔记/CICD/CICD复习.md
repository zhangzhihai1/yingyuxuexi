# 1.jenkins

## 1.1基础环境

```powershell
https://www.jenkins.io/doc/book/installing/kubernetes/   基于kubernetes部署

插件目录/var/lib/jenkins/plugins/

镜像源/var/lib/jenkins/updates/default.json

修改 Jenkins 的启动用户为 root

ssh优化：自动信任远程主机

执行者数量默认为cpu核数

备份还原/var/lib/jenkins，自己写备份脚本 或者同步脚本

找回密码
```

## 1.2CICD

```powershell
freestyle：新建->配置（源码管理，触发器）->构建步骤：配置各种脚本(shell直接复制粘贴，标准写法)，编译打包上传镜像制品->构建后操作sed k8s.yaml的image(tag为时间戳或v)
freestyle：不建议拉多个仓库，只能拉一个仓库最好能直接编译打包的

可以先写好脚本再在shell上bash执行（有deploy和rollback两种方法），如果是k8s，完全可以使用kubectl回滚

参数化构建：勾选This project is parameterized->添加参数(如$var_choice)->测试/生产（case $branch）
利用 Git Parameter 插件实现拉取指定 Commit_ID
mvn clean package -DskipTests：跳过测试执行，但依然编译测试代码
-Dmaven.test.skip=true：连测试代码的编译都跳过

环境变量：任务中的自定义的变量 > Jenkins 的自定义环境量 > Jenkins 内置的环境变量

凭据：用户名密码/api token/证书/ssh秘钥...
在jenkins服务器上生成密钥对,jenkins服务启动身份为root，在GitLab中项目具有访问权限的用户帐号的profile（个人设置）中导入Jenkins的公钥

ansible插件，mailer插件（通知），钉钉自定义机器人webhook，dingtalk插件（pipeline实现）
Qy Wechat Notification

自动化构建（触发器）：cron(周期性触发构建)/SCM(轮询代码变更)/webhook(提交代码自动执行构建)/项目关联

Blue Ocean任务可视化

镜像制作：docker-build-step

集成k8s（都需要kubeconfig）：1.在 Jenkins 上安装 kubectl  2.安装插件：Kubernetes CLI Plugin  3.脚本ssh
```

依赖管理

```powershell
本地maven    +  远程nexus
打包方式，直接用胖jar或者用瘦jar+依赖部署（多阶段构建直接先将依赖部署环境再部署jar包制作为镜像）
```

审核

```powershell
input message: '审批部署到生产环境', ok: '批准',
      submitter: 'alice,bob'

Role-based Authorization Strategy插件RABC       item role对应job
```

脚本案例

```powershell
配置了源码管理的情况
#!/bin/bash

TIMESTAMP=$(date +%Y%m%d%H%M%S)
cd "$WORKSPACE" || exit 1

# 使用 Jenkins 提供的 Git commit
GIT_COMMIT_SHORT=$(echo $GIT_COMMIT | cut -c1-7)
IMAGE_NAME="harbor.example.com/dev/demo"
IMAGE_TAG="${TIMESTAMP}-${GIT_COMMIT_SHORT}"

echo ">>> 构建镜像：${IMAGE_NAME}:${IMAGE_TAG}"

# Maven 构建
mvn clean package -Dmaven.test.skip=true

# 构建镜像
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# 推送镜像
docker login harbor.example.com -u admin -p admin123
docker push ${IMAGE_NAME}:${IMAGE_TAG}

# 更新 YAML 中 image
sed -i "s#image: ${IMAGE_NAME}:.*#image: ${IMAGE_NAME}:${IMAGE_TAG}#g" k8s/deployment.yaml

echo ">>> 镜像推送成功，YAML 已更新"
```

pipeline案例

## 1.3jenkins高级

```powershell
jenkins分布式：jenkins master(大脑)/jenkins agent(执行任务，k8sagent自动伸缩)
ssh:SSH Build Agents

分布式系统：多地区多节点                    K8s
分布式应用：多模块多节点                  Spring Cloud
分布式数据库：多节点分布存储，支持统一访问         mongodb
分布式存储：文件/对象存储分布于多个节点             Ceph
分布式计算：计算任务拆分，分发到多个节点处理       Spark、Flink、MapReduce
分布式缓存：缓存数据在多个节点                   Redis Cluster
分布式锁：在多节点系统中确保“互斥”执行          Redis RedLock


分布式最大的优点是什么，容错/故障自愈，弹性伸缩，可扩展性吗，高可用高性能
```

# 2.gitlab

```powershell
sudo gitlab-rails console     控制台，更改密码等
配置/etc/gitlab/gitlab.rb           gitlab-ctl reconfigure/restart/status
备份恢复：gitlab-backup 
```

命令

```powershell
cd D:\IdeaProjects\yudao-cloud-mini\
git init
git add .
git commit -m "init"
git checkout -b feature/dev-zzh
git remote add origin http://10.0.0.168/yudao-cloud-mini.git
git remote set-url origin http://10.0.0.168/yudao-cloud/yudao-cloud-mini.git
git remote -v

git push -u origin feature/dev-zzh
git checkout master
git merge feature/dev-zzh          本地master
git push -u origin master          不成功，因为master受保护
git log master
git log feature/dev-zzh
git branch --merged
```

# 3.sonarqube

```powershell

```

