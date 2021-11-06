# 用traefik进行反向代理的npm私有仓库部署方案

docker-compose + verdaccio + traefik搭建的npm私有仓库。  

## 优势
1. 只需要docker环境，不依赖其他服务。
2. 快速实现https。

## 适用场景
已经或计划使用docker-compose安装traefik进行http服务管理的服务器

## 依赖
1. [docker](https://wiki.liujin.site/zh/docker/install)
2. [docker-compose](https://wiki.liujin.site/zh/docker-compose/install)
3. [traefik](https://wiki.liujin.site/zh/docker-compose/traefik)

## 配置文件

+ docker-compose.yml
```yaml
version: '3.7'
services:
  npm:
    image: verdaccio/verdaccio
    # 以下labels为traefik相关的配置
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"
      - "traefik.http.routers.npm.rule=Host(`npm.example.net`)" # Host根据实际域名配置
      - "traefik.http.routers.npm.entrypoints=https"
      - "traefik.http.routers.npm.tls=true"
      - "traefik.http.routers.npm.tls.certresolver=letsencrypt"
      - "traefik.http.routers.npm.service=npm"
      - "traefik.http.services.npm.loadbalancer.server.port=4873"
      - "traefik.http.services.npm.loadbalancer.server.scheme=http"

      # http跳转https
      - 'traefik.http.routers.npm-http.rule=Host(`npm.example.net`)'
      - 'traefik.http.routers.npm-http.middlewares=https@docker'
      - 'traefik.http.routers.npm-http.entrypoints=http'
    restart: always

    volumes:
      - ./verdaccio:/verdaccio
    networks:
      - default
      - traefik

networks:
  default:

  # traefik的网络
  traefik:
    external:
      name: traefik
```

+ verdaccio/conf/config.yaml
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
2. 安装[traefik](https://wiki.liujin.site/zh/docker-compose/traefik)
3. 下载代码
```shell
git clone https://github.com/liujin0215/docker-compose.git
```
4. 进入对应文件夹
```shell
cd docker-compose/npm/traefik
```
5. 根据实际情况修改配置文件: `docker-compose.yml`, `verdaccio/conf/config.yaml`
6. 启动服务
```shell
docker-compose up -d
```
7. 浏览器打开`https://npm.example.net`(打开实际配置的域名), 看到如下界面即成功部署完成
![npm.png](https://wiki.liujin.site/npm.png)