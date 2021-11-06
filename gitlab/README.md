# gitlab的部署方案

docker-compose + gitlab + traefik搭建的gitlab服务。  

## 优势
1. 只需要docker环境，不依赖其他服务。
2. 快速实现https。
3. 部署快速，配置简单。

## 适用场景
适用于未部署且不打算部署其他占用80，443端口的服务的服务器。

## 依赖
1. [docker](https://wiki.liujin.site/zh/docker/install)
2. [docker-compose](https://wiki.liujin.site/zh/docker-compose/install)

## 配置文件

- docker-compose.yml
```yaml
version: '3.7'
services:
  traefik:
    image: traefik:v2.5
    restart: always
    volumes:
      - ./traefik:/etc/traefik
      - ./log:/log
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80
      - 443:443

  gitlab:
    image: gitlab/gitlab-ce:13.4.1-ce.0
    restart: always
    environment:
      # 时区，根据实际情况配置
      TZ: 'Asia/Shanghai'
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"
      - "traefik.http.routers.gitlab.rule=Host(`gitlab.example.net`)"
      - "traefik.http.routers.gitlab.entrypoints=https"
      - "traefik.http.routers.gitlab.tls=true"
      - "traefik.http.routers.gitlab.service=gitlab"
      - "traefik.http.services.gitlab.loadbalancer.server.port=80"
      - "traefik.http.services.gitlab.loadbalancer.server.scheme=http"

      # http跳转https的中间件
      - "traefik.http.middlewares.https.redirectscheme.scheme=https"
      - "traefik.http.middlewares.https.redirectscheme.permanent=true"

      # http跳转https
      - 'traefik.http.routers.gitlab-http.rule=Host(`gitlab.example.net`)'
      - 'traefik.http.routers.gitlab-http.middlewares=https@docker'
      - 'traefik.http.routers.gitlab-http.entrypoints=http'
    ports:
      - '1022:22'
    volumes:
      - './gitlab:/etc/gitlab'
      - './log:/var/log/gitlab'
      - './data:/var/opt/gitlab'
```

- gitlab/gitlab.rb
```ruby
# 根据实际情况修改域名
external_url 'https://gitlab.example.net'
gitlab_rails['gitlab_ssh_host'] = 'gitlab.example.net'

# ssh端口
gitlab_rails['gitlab_shell_ssh_port'] = 1022

# email配置, 可不配置
gitlab_rails['gitlab_email_from'] = 'gitlab@example.net'
gitlab_rails['gitlab_email_display_name'] = 'Gitlab'
gitlab_rails['gitlab_email_reply_to'] = 'gitlab@example.net'
gitlab_rails['gitlab_email_subject_suffix'] = ''
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "mail.example.net"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "gitlab@example.net"
gitlab_rails['smtp_password'] = "Gitlab"
gitlab_rails['smtp_domain'] = "mail.example.net"
gitlab_rails['smtp_authentication'] = "plain"
gitlab_rails['smtp_enable_starttls_auto'] = true

# nginx配置
nginx['client_max_body_size'] = '250m'
nginx['listen_port'] = 80
nginx['listen_https'] = false
```

- traefik/traefik.yml
```yaml
providers:
  docker:
    watch: true
    exposedByDefault: false
entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      # email 根据实际情况进行修改
      email: XXX@xxx.xxx
      storage: acme.json
      httpChallenge:
        entryPoint: http

log:
  # 调试阶段可改为DEBUG
  level: ERROR

accessLog:
   filePath: /log/access.log
```

## 命令
1. 启动服务
```shell
docker-compose up -d
```
2. 关闭服务
```shell
docker-compose down
```
3. 重启服务
```shell
docker-compose restart
```

## 步骤
1. 安装[docker](https://wiki.liujin.site/zh/docker/install)和[docker-compose](https://wiki.liujin.site/zh/docker-compose/install)
2. 下载代码
```shell
git clone https://github.com/liujin0215/docker-compose.git
```
3. 进入对应文件夹
```shell
cd docker-compose/gitlab
```
4. 根据实际情况修改配置文件: `docker-compose.yml`, `gitlab/gitlab.rb`, `traefik/traefik.yml`
5. 启动服务
```shell
docker-compose up -d
```
6. 浏览器打开`https://gitlab.example.net`(打开实际配置的域名), 由于gitlab初始化需要一定时间，可能需要等几分钟，直到看到如下界面即成功部署完成
![gitlab.png](https://wiki.liujin.site/gitlab.png)
