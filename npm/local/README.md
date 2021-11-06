# 简单的npm私有仓库部署方案

docker-compose + verdaccio搭建的npm私有仓库。  

## 优势
1. 只需要docker环境，不依赖其他服务。
2. 2个配置文件即可快速高效搭建npm私有仓库。

## 适用场景
只想简单部署一个私有npm仓库，不需要https，或可通过其他服务(nginx等)进行反向代理。

## 依赖
1. [docker](https://wiki.liujin.site/zh/docker/install)
2. [docker-compose](https://wiki.liujin.site/zh/docker-compose/install)

## 配置文件

- docker-compose.yml
```yaml
version: '3.7'
services:
  npm:
    image: verdaccio/verdaccio
    
    restart: always
    volumes:
      - ./verdaccio:/verdaccio
    ports:
      - 4873:4873
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
cd docker-compose/npm/local
```
4. 根据实际情况修改配置文件: `docker-compose.yml`, `verdaccio/conf/config.yaml`
5. 启动服务
```shell
docker-compose up -d
```
6. 浏览器打开`http://localhost:4873`(打开实际服务器的IP), 看到如下界面即成功部署完成
![npm.png](https://wiki.liujin.site/npm.png)