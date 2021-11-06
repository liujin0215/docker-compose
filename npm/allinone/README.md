# 用docker-compose部署all in one的npm私有仓库的方案

docker-compose + verdaccio + traefik搭建的npm私有仓库。  

## 优势
1. 只需要docker环境，不依赖其他服务。
2. 快速实现https。

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
      - ./verdaccio:/verdaccio
      - ./log:/log
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80
      - 443:443

  npm:
    image: verdaccio/verdaccio
    labels:
      - "traefik.enable=true"
      # Host根据实际情况进行修改
      - "traefik.http.routers.npm.rule=Host(`npm.example.net`)"
      - "traefik.http.routers.npm.entrypoints=https"
      - "traefik.http.routers.npm.tls=true"
      - "traefik.http.routers.npm.tls.certresolver=letsencrypt"

      # http跳转https的中间件
      - "traefik.http.middlewares.https.redirectscheme.scheme=https"
      - "traefik.http.middlewares.https.redirectscheme.permanent=true"

      # http跳转https
      - 'traefik.http.routers.npm-http.rule=Host(`npm.example.net`)'
      - 'traefik.http.routers.npm-http.middlewares=https@docker'
      - 'traefik.http.routers.npm-http.entrypoints=http'
    restart: always
    volumes:
      - ./verdaccio:/verdaccio
```

- verdaccio/conf/config.yaml
```yaml
storage: /verdaccio/storage/data
plugins: /verdaccio/plugins

web:
  title: Verdaccio

auth:
  htpasswd:
    file: /verdaccio/storage/htpasswd

# 上游的npm仓库,中国配置taobao的npm仓库即可
uplinks:
  npmjs:
    url: https://registry.npm.taobao.org/

packages:
  '@*/*':
    # scoped packages
    access: $all
    publish: $authenticated
    unpublish: $authenticated
    proxy: npmjs

  '**':
    access: $all
    publish: $authenticated
    unpublish: $authenticated
    proxy: npmjs

server:
  keepAliveTimeout: 60

middlewares:
  audit:
    enabled: true

logs: { type: stdout, format: pretty, level: http }
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
cd docker-compose/npm/allinone
```
4. 根据实际情况修改配置文件: `docker-compose.yml`, `verdaccio/conf/config.yaml`, `traefik/traefik.yml`
5. 启动服务
```shell
docker-compose up -d
```
6. 浏览器打开`https://npm.example.net`(打开实际配置的域名), 看到如下界面即成功部署完成
![npm.png](https://wiki.liujin.site/npm.png)