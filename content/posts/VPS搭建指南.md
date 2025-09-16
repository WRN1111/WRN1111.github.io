+++
date = '2025-09-13T12:43:29Z'
draft = false
title = '国外VPS搭建节点教程'
+++

首先购买VPS，注意最好有原生的IPV4，纯IPV6的话去Github拉取东西都费劲。

地域为了延迟可以选香港，但是香港是GPT不支持的地方，哪怕套了CF照样不支持，所以优先台湾，日本。

注意！只看“KVM VPS”，其它的比如“Hosting”是拿来建网站的，不能拿来翻墙。

目前有两种方式：

1. VLESS + WebSocket + TLS

传输层：

使用 WebSocket（WS）作为传输，表面上看起来像普通的 HTTPS 流量。

加密：

依赖 TLS（通常配合域名证书，比如 Cloudflare、Let’s Encrypt）。

需要一个 域名，而且证书要合法。

优点：

可以伪装成正常的网站流量。

很常见，教程多、兼容性强。

缺点：

必须要域名、证书。

流量特征虽然像 HTTPS，但还是容易被 DPI 检测到 WS 模式。

需要额外配置（Nginx/Caddy/Cloudflare 等）。

2. VLESS + Reality

传输层：

不用 WebSocket，也不用真正的网站。

通过 Reality 技术来“伪造”一个看起来像 TLS 的握手。

加密：

内部是 基于 XTLS 的加密传输，客户端和服务端共享一个公钥/私钥。

不需要申请域名和证书。

原理：

它会模拟访问一个大网站（比如 www.microsoft.com 或 www.cloudflare.com），让流量看起来完全像真实的 TLS。

优点：

免域名、免证书，部署更简单。

伪装效果更强，几乎就是正经网站的 TLS 流量。

性能更好，延迟更低。

缺点：

需要支持 Reality 的客户端（比较新的 Clash / v2rayN / sing-box 等）。

相对比较新，教程少一些。

VLESS+Websocket+TLS 模式需要你自已有一个域名.

以下步骤, 以namesilo购买首年$1域名为例:

访问namesilo.com
https://www.namesilo.com/?rid=ef95362qr

4. 添加到Cloudflare的DNS解析
namesilo 的DNS解析很慢。建议改到Cloudflare解析，还可以开CDN.
注册cloudflare.com
打开 https://www.cloudflare.com/ 注册一个账户
添加你的域名
选择添加站点，输入你申请的域名-选择免费计划

添加DNS解析
点击“添加记录”，“名称”中输入@，IPv4地址输入VPS的公网IP（还记得VPS发来的邮件吗？）代理状态那里要点一下图标，从橙色的云朵“已代理”变成灰色的云朵“仅限DNS”，点击“保存”。

在接下来的页面中，注意记下两项
“名称服务器”的信息

登录 namesilo.com
https://www.namesilo.com/account_domains.php?rid=ef95362qr

管理你的域名

namesilo 修改域名相关设置

修改名称服务器 NameServer

将原有的NameSever全部删掉，填写Cloudflare指定的2个名称服务器. (还记得前面Cloudflare操作的最后一步吗?)

======================

名称服务器 NameServer的转移需要一段时间，

登录Cloudflare，看看你的域名状态，如果是下面这样“待处理的名称服务器更新”，你还需要等待。如果名称服务器切换成功，Cloudflare会给你发邮件的，请关注你的邮箱。

如果状态为绿色的对勾，那么说明名称服务器切换生效了。

“SSL/TLS”，设置为“完全”。

=======================================
5. 操作命令行在VPS上安装V2Ray Reality模式
更新一下软件源信息。输入以下命令，回车。

先安装https://github.com/MHSanaei/3x-ui/blob/main/README.zh_CN.md

之后自定义端口，UFW放行，管理面板。

但此时还是http协议，直接输入用户名密码很危险，所以要在本地设置SSH转发，ssh -L xxxxx:localhost:xxxxx username@ip -p 

之后在浏览器访问localhost:xxxxx 登陆进去，将公钥和证书设置好。

之后就可以使用域名登录了
接下来可以找一个订阅转换链接转换为clash格式，也可以直接用v2ray

之后需要设置warp来保证自己ip安全点
设置warp，设置路由规则，注意要放行ssh和自己的域名


