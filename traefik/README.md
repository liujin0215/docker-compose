# traefik基于docker-compose的安装

## 依赖
1. [docker](https://wiki.liujin.site/zh/docker/install)
2. [docker-compose](https://wiki.liujin.site/zh/docker-compose/install)

## 安装
1. 创建docker网络
```shell
docker network create -d bridge traefik
```

2. 创建认证用户
```shell
docker run --rm -it -v `pwd`/etc/passwd:/passwd --entrypoint /usr/local/apache2/bin/htdigest httpd:alpine -c /passwd/digestauth traefik test
```
此处最后的"test"是用户名，根据实际情况进行自定义即可

3. 修改配置文件
- docker-compose.yml
```yaml
version: '3.7'
services:
  traefik:
    image: traefik:v2.5
    restart: always
    volumes:
      - ./etc:/etc/traefik
      - ./log:/log
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - traefik
    labels:
      # digestauth中间件，用于认证
      - "traefik.http.middlewares.digestauth.digestauth.usersfile=/etc/traefik/passwd/digestauth"
      - 'traefik.enable=true'
      # Host根据实际情况进行修改
      - 'traefik.http.routers.api.rule=Host(`traefik.example.net`)'
      - 'traefik.http.routers.api.entrypoints=https'
      - 'traefik.http.routers.api.service=api@internal'
      - 'traefik.http.routers.api.tls=true'
      - 'traefik.http.routers.api.tls.certresolver=letsencrypt'
      # 使用digestauth进行认证
      - 'traefik.http.routers.api.middlewares=digestauth@docker'
    ports:
      - 80:80
      - 443:443

networks:
  traefik:
    external:
      name: traefik
```
- etc/traefik.yml
```yaml
api: {}
providers:
  docker:
    watch: true
    exposedByDefault: false
  file:
    directory: /etc/traefik/conf.d
    watch: true
entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"

certificatesResolvers:
  # 用letsencrypt进行https认证
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

4. 启动
```shell
docker-compose up -d
```

## 测试
从浏览器打开`https://traefik.example.net`，输入账号密码