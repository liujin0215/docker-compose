# 用traefik进行反向代理的minio部署方案

docker-compose + minio + traefik搭建的S3服务。  

## 优势
1. 只需要docker环境，不依赖其他服务。
2. 快速实现https。
3. 部署快速，配置简单。

## 适用场景
已经或计划使用docker-compose安装traefik进行http服务管理的服务器

## 其他方案
- [all in one的minio的部署方案](../allinone) 

## 依赖
1. [docker](https://wiki.liujin.site/zh/docker/install)
2. [docker-compose](https://wiki.liujin.site/zh/docker-compose/install)
3. [traefik](https://wiki.liujin.site/zh/docker-compose/traefik)

## 配置文件

- docker-compose.yml
```yaml
version: '3.7'
services:
  minio:
    image: minio/minio:latest
    restart: always
    labels:
      - "traefik.enable=true"

      # Host根据实际情况进行修改
      - "traefik.http.routers.minio.rule=Host(`minio.example.net`)"
      - "traefik.http.routers.minio.entrypoints=https"
      - "traefik.http.routers.minio.tls=true"
      - "traefik.http.routers.minio.service=minio"
      - "traefik.http.services.minio.loadbalancer.server.port=9000"
      - "traefik.http.services.minio.loadbalancer.server.scheme=http"

      # Host根据实际情况进行修改
      - "traefik.http.routers.minioadmin.rule=Host(`minioadmin.example.net`)"
      - "traefik.http.routers.minioadmin.entrypoints=https"
      - "traefik.http.routers.minioadmin.tls=true"
      - "traefik.http.routers.minioadmin.service=minioadmin"
      - "traefik.http.services.minioadmin.loadbalancer.server.port=9001"
      - "traefik.http.services.minioadmin.loadbalancer.server.scheme=http"

      # http跳转https
      - 'traefik.http.routers.minio-http.rule=Host(`minio.example.net`)'
      - 'traefik.http.routers.minio-http.middlewares=https@docker'
      - 'traefik.http.routers.minio-http.entrypoints=http'
      - "traefik.http.routers.minio-http.service=minio-http"
      - "traefik.http.services.minio-http.loadbalancer.server.port=9000"
      - "traefik.http.services.minio-http.loadbalancer.server.scheme=http"

      # http跳转https
      - 'traefik.http.routers.minioadmin-http.rule=Host(`minioadmin.example.net`)'
      - 'traefik.http.routers.minioadmin-http.middlewares=https@docker'
      - 'traefik.http.routers.minioadmin-http.entrypoints=http'
      - "traefik.http.routers.minioadmin-http.service=minioadmin-http"
      - "traefik.http.services.minioadmin-http.loadbalancer.server.port=9001"
      - "traefik.http.services.minioadmin-http.loadbalancer.server.scheme=http"
    command: server /data --console-address ":9001"
    env_file:
      - ./.env
    volumes:
      - ./data:/data
```

- .env
```sh
# root用户名，根据实际情况进行自定义
MINIO_ROOT_USER="USERNAME"
# root密码，根据实际情况进行自定义
MINIO_ROOT_PASSWORD="PASSWORD"

MINIO_BROWSER="on"

# 根据实际情况配置域名
MINIO_SERVER_URL="https://minio.example.net"
MINIO_BROWSER_REDIRECT_URL="https://minioadmin.example.net"
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
cd docker-compose/minio/traefik
```
5. 根据实际情况修改配置文件: `docker-compose.yml`, `.env`
6. 启动服务
```shell
docker-compose up -d
```
7. 浏览器打开`https://minio.example.net`(打开实际配置的域名), 直到看到如下界面即成功部署完成  
![minio.png](https://wiki.liujin.site/minio.png)

