# godaddy-ddns-bash

自动更新当前 IP 地址到 godaddy 域名解析中。脚本通过 systemd 托管运行。

# 安装

    make install

会自动创建默认配置模板和复制脚本到 /etc/godaddy-ddns

编辑 cat /etc/godaddy-ddns/ddns.env 文件修改配置参数

# 参数

API-KEY 从 https://developer.godaddy.com/keys/ 获取。

| 命令行参数 | 环境变量参数 | 描述 |
|  ----  |  ----  |  ----  |
| --key  | GODADDY_DDNS_KEY | API-KEY |
| --secret  | GODADDY_DDNS_SECRET | API-SECRET |
| --name  | GODADDY_DDNS_NAME | 解析名称 (例如 name.abc.com 中的 name) |
| --domain | GODADDY_DDNS_DOMAIN | 域名名称 (例如 name.abc.com 中的 abc.com) |
| --get-ip-url | GODADDY_DDNS_GET_IP_URL | 重新指定获取当前 IP 的服务地址，默认为 https://icanhazip.com |
| --interval | GODADDY_DDNS_INTERVAL | 检查间隔，单位秒，默认 300 |
| --ttl | GODADDY_DDNS_TTL | 指定域名TTL，默认 600 |
| --ipv6 | GODADDY_DDNS_IPV6 | 强制使用 IPV6 请求当前公网地址，默认 0 |

# 启动

使用 systemd 运行

    $ sudo systemctl --system daemon-reload
    $ sudo systemctl enable godaddy-ddns

检查是否启动成功

    $ sudo systemctl status godaddy-ddns

启用开机运行

    $ sudo systemctl enable godaddy-ddns

# 使用 IPV6 

使用前确保机器已经分配了IPV6地址。

由于单个脚本不支持更新多个路径，请复制一份 systemd 配置或者直接修改默认配置强制使用IPV6：

1.直接修改 /etc/godaddy-ddns/ddns.env

    GODADDY_DDNS_IPV6=1

2.额外启用一个 IPV6 版本进程

    $ cp /etc/systemd/system/godaddy-ddns.service /etc/systemd/system/godaddy-ddns6.service
    $ cp /etc/godaddy-ddns/ddns.env /etc/godaddy-ddns/ddns6.env


修改 /etc/godaddy-ddns/ddns.env

    GODADDY_DDNS_IPV6=1


修改 /etc/systemd/system/godaddy-ddns6.service

    ExecStart=/usr/bin/bash /etc/godaddy-ddns/godaddy-ddns.bash /etc/godaddy-ddns/ddns6.env

使用 systemd 运行

    $ sudo systemctl --system daemon-reload
    $ sudo systemctl enable godaddy-ddns6

# LICENSE

MIT