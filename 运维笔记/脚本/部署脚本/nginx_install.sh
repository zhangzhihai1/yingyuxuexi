#!/bin/bash
#
#****************************************************
#Author:         zhangzhihai
#Date:           2025-06-10 
#FileName:       nginx_install.sh
#Description:    test
#***************************************************


#一旦有命令失败立即退出
set -e

LOG_FILE="/data/shell/install.log"
#替换当前进程的IO重定向

exec > >(tee -a "$LOG_FILE") 2>&1
# 安装依赖（适配Rocky9的dnf包管理器）
dnf install -y gcc make pcre-devel zlib-devel openssl-devel wget tar || {
    echo "依赖安装失败，请检查网络或软件源配置" >&2
    exit 1
}

echo "【$(date '+%Y-%m-%d %H:%M:%S')】开始安装 Nginx"

NGINX_VERSION="1.26.2"
INSTALL_DIR="/usr/local/nginx"
SRC_DIR="/tmp/nginx-${NGINX_VERSION}"
TARBALL="nginx-${NGINX_VERSION}.tar.gz"

# 检查并清理旧安装
if [ -d "$INSTALL_DIR" ]; then
    echo "检测到现有 Nginx 安装，是否覆盖？(y/N)"
    read -n1 choice
    [[ "$choice" != "y" && "$choice" != "Y" ]] && exit 1
    rm -rf "$INSTALL_DIR"
fi

# 下载解压
cd /tmp
# 判断是否已有源码包
if [ -f "$TARBALL" ]; then
    echo "检测到文件 $TARBALL 已存在，是否跳过下载并继续安装？(y/N)"
    read -n1 choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "操作已取消"
        exit 1
    fi
else
    echo "正在下载 Nginx ${NGINX_VERSION}..."
    wget "http://nginx.org/download/${TARBALL}" || {
        echo "下载失败，请检查网络连接" >&2
        exit 1
    }
fi

# 解压源码包
if [ -d "$SRC_DIR" ]; then
    echo "检测到源码目录 $SRC_DIR 已存在，是否清理后重新解压？(y/N)"
    read -n1 choice
    echo
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        rm -rf "$SRC_DIR"
        tar zxvf "$TARBALL"
    else
        echo "将使用现有源码目录继续编译"
    fi
else
    tar zxvf "$TARBALL"
fi

cd "$SRC_DIR" || exit 1

# 创建运行用户
if ! id nginx &>/dev/null; then
    groupadd -r nginx
    #-M	不创建用户的家目录，-d指定用户家目录
    useradd -r -g nginx -s /sbin/nologin -M -d /var/cache/nginx nginx
fi

# 创建缓存目录
mkdir -p /var/cache/nginx
chown nginx:nginx /var/cache/nginx

# 编译配置
./configure \
    --prefix="$INSTALL_DIR" \
    --user=nginx \
    --group=nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-pcre \
    --with-threads \
    --with-file-aio \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module

#-j：表示并行编译（多线程编译）,你的服务器是 4 核 CPU，nproc 就会返回 4
make -j$(nproc) && make install

# systemd 服务
cat > /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx service
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=${INSTALL_DIR}/logs/nginx.pid
ExecStart=${INSTALL_DIR}/sbin/nginx
ExecReload=${INSTALL_DIR}/sbin/nginx -s reload
ExecStop=${INSTALL_DIR}/sbin/nginx -s quit
#为该服务创建一个私有的临时目录 /tmp，与系统的 /tmp 隔离
PrivateTmp=true
WorkingDirectory=${INSTALL_DIR}

#打开文件限制，系统一般限制1024/4096，所以还要进行系统优化后才有可能生效，比如更改硬限制
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable --now nginx

# 创建软链接便于全局调用
if [ -L "/usr/sbin/nginx" ]; then
    echo "/usr/sbin/nginx 已存在为软链接，是否重新创建？(y/N)"
    read -n1 choice
    echo
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        rm -f "/usr/sbin/nginx"
        ln -sf "${INSTALL_DIR}/sbin/nginx" /usr/sbin/nginx
        echo "已重新创建软链接 /usr/sbin/nginx"
    else
        echo "保留现有软链接"
    fi
elif [ -e "/usr/sbin/nginx" ]; then
    echo "警告：/usr/sbin/nginx 已存在且不是软链接，跳过创建"
else
    ln -sf "${INSTALL_DIR}/sbin/nginx" /usr/sbin/nginx
    echo "已创建软链接 /usr/sbin/nginx"
fi

# 输出结果
echo "安装完成，访问地址: http://$(hostname -I | awk '{print $1}')，，虚拟机可访问，主机不行注意关闭防火墙"
