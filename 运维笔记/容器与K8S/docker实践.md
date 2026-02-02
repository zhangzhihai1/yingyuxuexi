# docker案例

一些操作在k8s实践中实现

## wordpress

```powershell
#方法1
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=123456 -e
MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=123456 
registry.cn-beijing.aliyuncs.com/wangxiaochun/mysql:8.0.29-oracle
#连接数据库的信息通过环境变量指定，MySQL容器重启IP可能会发生变化
docker run -d --name wordpress -p 80:80 -e WORDPRESS_DB_HOST=`docker inspect 
mysql --format "{{.NetworkSettings.Networks.bridge.IPAddress}}"` -e
WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=123456 -e
WORDPRESS_DB_NAME=wordpress registry.cn-beijing.aliyuncs.com/wangxiaochun/wordpress:php8.2-apache

#方法2：需要初始化人为输入连接数据库信息
docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e
MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=123456 
registry.cn-beijing.aliyuncs.com/wangxiaochun/mysql:8.0.29-oracle
#连接数据库的主机：宿主机的IP
docker run -d -p 80:80 --name wordpress -e WORDPRESS_DB_HOST=<宿主机的IP>  -e
WORDPRESS_DB_USER=wordpress -e WORDPRESS_DB_PASSWORD=123456 -e
WORDPRESS_DB_NAME=wordpress registry.cn-beijing.aliyuncs.com/wangxiaochun/wordpress:php8.2-apache
docker run -d --name wordpress -p 80:80 registry.cn-beijing.aliyuncs.com/wangxiaochun/wordpress:php8.2-apache
```

## 热迁移

rocky直接yum -y install,环境必须相同

1.安装criu

```powershell
#Ubuntu24.04默认没有criu包,需要添加安装源
[root@ubuntu2404 ~]#add-apt-repository ppa:criu/ppa -y && apt update && apt -y install criu docker.io
```

```powershell
#!/bin/bash
# CRIU 安装和配置脚本

# 安装 CRIU
install_criu() {
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y criu
    elif command -v yum &> /dev/null; then
        sudo yum install -y criu
    else
        echo "不支持的包管理器"
        exit 1
    fi
}

# 配置 Docker 启用实验特性
configure_docker() {
    # 备份原有配置
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || true
    
    # 创建或修改配置
    echo '{
        "experimental": true,
        "live-restore": true
    }' | sudo tee /etc/docker/daemon.json
    
    # 重启 Docker
    sudo systemctl restart docker
}

# 检查内核支持
check_kernel_support() {
    echo "检查内核支持..."
    
    # 检查必要的内核配置
    required_configs=(
        "CONFIG_CHECKPOINT_RESTORE"
        "CONFIG_NAMESPACES"
        "CONFIG_PID_NS"
        "CONFIG_NET_NS"
    )
    
    for config in "${required_configs[@]}"; do
        if ! grep -q "${config}=y" /boot/config-$(uname -r) 2>/dev/null; then
            echo "警告: 内核可能不支持 ${config}"
        fi
    done
}

# 主安装流程
main() {
    echo "开始安装 CRIU 和配置 Docker..."
    
    install_criu
    configure_docker
    check_kernel_support
    
    echo "安装完成！请重启系统或重新登录使配置生效"
}

main "$@"
```

2.迁移

```powershell
#!/bin/bash
set -e

# 配置参数
CONTAINER_NAME=$1
DESTINATION_HOST=$2
CHECKPOINT_DIR="/tmp/criu_checkpoints"
MIGRATION_DIR="/tmp/migration_data"

# 颜色输出函数
color() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
    
    case $2 in
        "success") echo -e "${GREEN}$1${NC}" ;;
        "error") echo -e "${RED}$1${NC}" ;;
        "warning") echo -e "${YELLOW}$1${NC}" ;;
        *) echo "$1" ;;
    esac
}

# 检查参数
if [ $# -ne 2 ]; then
    color "用法: $0 <容器名> <目标主机>" "error"
    exit 1
fi

# 检查 CRIU 支持
check_criu_support() {
    if ! command -v criu &> /dev/null; then
        color "错误: CRIU 未安装" "error"
        exit 1
    fi
    
    # 检查内核支持
    if [ ! -e /proc/self/ns/net ]; then
        color "错误: 内核不支持命名空间" "error"
        exit 1
    fi
}

# 创建检查点
create_checkpoint() {
    color "创建容器检查点..." "warning"
    
    # 清理旧检查点
    rm -rf "${CHECKPOINT_DIR}/${CONTAINER_NAME}"
    mkdir -p "${CHECKPOINT_DIR}/${CONTAINER_NAME}"
    
    # 创建检查点
    if docker checkpoint create --checkpoint-dir="${CHECKPOINT_DIR}" "${CONTAINER_NAME}" "migration_point"; then
        color "检查点创建成功" "success"
    else
        color "检查点创建失败" "error"
        exit 1
    fi
}

# 准备迁移数据
prepare_migration_data() {
    color "准备迁移数据..." "warning"
    
    # 创建迁移目录
    rm -rf "${MIGRATION_DIR}"
    mkdir -p "${MIGRATION_DIR}"
    
    # 导出容器配置
    docker inspect "${CONTAINER_NAME}" > "${MIGRATION_DIR}/container_config.json"
    
    # 复制检查点数据
    cp -r "${CHECKPOINT_DIR}/${CONTAINER_NAME}" "${MIGRATION_DIR}/checkpoint"
    
    # 获取镜像信息
    LOCAL_IMAGE=$(docker inspect --format='{{.Config.Image}}' "${CONTAINER_NAME}")
    echo "${LOCAL_IMAGE}" > "${MIGRATION_DIR}/image_info"
}

# 传输数据到目标主机
transfer_data() {
    color "传输数据到目标主机 ${DESTINATION_HOST}..." "warning"
    
    # 使用 rsync 传输数据
    if rsync -avz --progress "${MIGRATION_DIR}/" "${DESTINATION_HOST}:${MIGRATION_DIR}/"; then
        color "数据传输成功" "success"
    else
        color "数据传输失败" "error"
        exit 1
    fi
}

# 在源主机停止容器（可选）
stop_source_container() {
    read -p "是否停止源容器? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop "${CONTAINER_NAME}"
        color "源容器已停止" "success"
    fi
}

# 主执行流程
main() {
    color "开始容器迁移: ${CONTAINER_NAME} -> ${DESTINATION_HOST}" "warning"
    
    check_criu_support
    create_checkpoint
    prepare_migration_data
    transfer_data
    stop_source_container
    
    color "迁移数据准备完成！请在目标主机运行恢复脚本" "success"
    echo "在目标主机执行: ./container_restore.sh ${CONTAINER_NAME}"
}

main "$@"
```

3.恢复

```powershell
#!/bin/bash
set -e

# 配置参数
CONTAINER_NAME=$1
MIGRATION_DIR="/tmp/migration_data"
CHECKPOINT_DIR="${MIGRATION_DIR}/checkpoint"

# 颜色输出函数
color() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
    
    case $2 in
        "success") echo -e "${GREEN}$1${NC}" ;;
        "error") echo -e "${RED}$1${NC}" ;;
        "warning") echo -e "${YELLOW}$1${NC}" ;;
        *) echo "$1" ;;
    esac
}

# 检查参数
if [ $# -ne 1 ]; then
    color "用法: $0 <容器名>" "error"
    exit 1
fi

# 检查迁移数据
check_migration_data() {
    if [ ! -d "${MIGRATION_DIR}" ]; then
        color "错误: 迁移数据不存在" "error"
        exit 1
    fi
    
    if [ ! -d "${CHECKPOINT_DIR}" ]; then
        color "错误: 检查点数据不存在" "error"
        exit 1
    fi
}

# 拉取镜像（如果需要）
pull_container_image() {
    local image=$(cat "${MIGRATION_DIR}/image_info")
    
    color "检查镜像: ${image}" "warning"
    
    if ! docker image inspect "${image}" &> /dev/null; then
        color "拉取镜像..." "warning"
        docker pull "${image}"
    else
        color "镜像已存在" "success"
    fi
}

# 恢复容器
restore_container() {
    local image=$(cat "${MIGRATION_DIR}/image_info")
    
    color "从检查点恢复容器..." "warning"
    
    # 创建容器（但不启动）
    docker create --name "${CONTAINER_NAME}" \
        $(jq -r '.[0].Config.Env[] | select(. != null) | "--env " + .' "${MIGRATION_DIR}/container_config.json") \
        $(jq -r '.[0].HostConfig.PortBindings | to_entries[]? | "-p " + .key + ":" + (.value[0].HostPort // "0")' "${MIGRATION_DIR}/container_config.json") \
        "${image}"
    
    # 从检查点恢复
    docker start --checkpoint="migration_point" --checkpoint-dir="${MIGRATION_DIR}/checkpoint" "${CONTAINER_NAME}"
    
    if [ $? -eq 0 ]; then
        color "容器恢复成功！" "success"
        
        # 显示容器状态
        echo -e "\n容器状态:"
        docker ps -f "name=${CONTAINER_NAME}"
    else
        color "容器恢复失败" "error"
        exit 1
    fi
}

# 清理迁移数据
cleanup_migration_data() {
    read -p "是否清理迁移数据? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "${MIGRATION_DIR}"
        color "迁移数据已清理" "success"
    fi
}

# 主执行流程
main() {
    color "开始恢复容器: ${CONTAINER_NAME}" "warning"
    
    check_migration_data
    pull_container_image
    restore_container
    cleanup_migration_data
    
    color "容器恢复完成！" "success"
}

main "$@"
```

```powershell
./container_migrate.sh my_container user@destination-host
./container_restore.sh my_container
```

## 自定义网络

### wordpress

```powershell

```

### redis cluster

```powershell

```

