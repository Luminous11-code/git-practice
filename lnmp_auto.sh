#!/bin/bash
# ==========================================
# LNMP + WordPress 自动化部署脚本
# 适用系统：Ubuntu 22.04
# 使用方法：chmod +x lnmp_auto.sh && ./lnmp_auto.sh
# ==========================================

set -e  # 遇到错误立即停止

# ---------- 变量定义（按需修改） ----------
MYSQL_ROOT_PASS="123456"                 # MySQL root 密码
WP_DB="wordpress"                        # WordPress 数据库名
WP_USER="wordpress_user"                 # WordPress 数据库用户名
WP_PASS="WordPress2026!"                 # WordPress 数据库用户密码
WP_ADMIN="Luminous11"                    # WordPress 管理员用户名
WP_ADMIN_PASS="your_strong_password"     # WordPress 管理员密码（自行修改）
WP_ADMIN_EMAIL="2651221243@qq.com"       # WordPress 管理员邮箱

# ---------- 颜色输出 ----------
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------- 开始安装 ----------
log_info "========== LNMP + WordPress 自动化部署开始 =========="

# 1. 更新系统
log_info "更新软件包列表..."
sudo apt update -y && sudo apt upgrade -y

# 2. 安装 Nginx
log_info "安装 Nginx..."
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# 3. 安装 MySQL
log_info "安装 MySQL..."
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

# 设置 MySQL root 密码
log_info "设置 MySQL root 密码..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASS';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 4. 安装 PHP
log_info "安装 PHP 及相关扩展..."
sudo apt install -y php8.1-fpm php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-zip php8.1-intl php8.1-soap php8.1-opcache

# 5. 配置 Nginx 支持 PHP
log_info "配置 Nginx..."
sudo tee /etc/nginx/sites-enabled/default > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name _;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo nginx -t
sudo systemctl reload nginx

# 6. 下载 WordPress
log_info "下载 WordPress..."
cd /var/www/html
sudo rm -rf /var/www/html/*
sudo wget https://cn.wordpress.org/latest-zh_CN.tar.gz
sudo tar -xzvf latest-zh_CN.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest-zh_CN.tar.gz
sudo chown -R www-data:www-data /var/www/html/

# 7. 创建 WordPress 数据库
log_info "创建 WordPress 数据库..."
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "CREATE DATABASE IF NOT EXISTS $WP_DB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "CREATE USER IF NOT EXISTS '$WP_USER'@'localhost' IDENTIFIED BY '$WP_PASS';"
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON $WP_DB.* TO '$WP_USER'@'localhost';"
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "FLUSH PRIVILEGES;"

# 8. 生成 wp-config.php
log_info "生成 wp-config.php..."
sudo tee /var/www/html/wp-config.php > /dev/null << EOF
<?php
define( 'DB_NAME', '$WP_DB' );
define( 'DB_USER', '$WP_USER' );
define( 'DB_PASSWORD', '$WP_PASS' );
define( 'DB_HOST', '127.0.0.1' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

sudo chown www-data:www-data /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php

# 9. 重启服务
log_info "重启 Nginx 和 PHP-FPM..."
sudo systemctl restart php8.1-fpm
sudo systemctl restart nginx

# 10. 获取本机 IP
SERVER_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)
if [ -z "$SERVER_IP" ]; then
	    SERVER_IP="你的虚拟机IP"
fi

log_info "========== 部署完成 =========="
echo ""
echo "✅ 访问 http://$SERVER_IP 完成 WordPress 安装"
echo ""
echo "数据库信息："
echo "  数据库名：$WP_DB"
echo "  用户名：$WP_USER"
echo "  密码：$WP_PASS"
echo ""
echo "WordPress 管理员（安装时设置）："
echo "  用户名：$WP_ADMIN"
echo "  邮箱：$WP_ADMIN_EMAIL"
