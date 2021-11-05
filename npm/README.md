# npm私有仓库

基于verdaccio搭建的npm私有仓库
## 依赖
1. [docker](https://wiki.liujin.site/zh/docker/install)
2. [docker-compose](https://wiki.liujin.site/zh/docker-compose/install)
3. traefik(非必须)

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
    restart: always

  # 可直接暴露端口
  # ports:
  #   - 4873:4873

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