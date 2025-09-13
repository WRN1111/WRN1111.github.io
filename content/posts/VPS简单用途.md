+++
date = '2025-09-13T12:43:29Z'
draft = false
title = '简易版CICD流程'
+++

🔧 目标

多个 GitHub 仓库（a-service、b-service、c-service …）

每个仓库 push → GitHub Actions：

编译打包 jar

构建 Docker 镜像

推送到 Docker Hub（或 GHCR、阿里云仓库等）

服务器运行一个统一的 docker-compose.yml，里面声明 a、b、c 服务 + 公共依赖（mysql、redis 等）

watchtower 常驻，检测到新镜像 → 自动拉取并更新对应容器

服务之间通过 docker 网络 互相调用（容器名就是主机名）

🏗️ 架构图
```
GitHub Repo A ----> GitHub Actions ----> Docker Hub (a-service:latest) --+
                                                                         |
GitHub Repo B ----> GitHub Actions ----> Docker Hub (b-service:latest) --+--> VPS (docker-compose + watchtower)
                                                                         |
GitHub Repo C ----> GitHub Actions ----> Docker Hub (c-service:latest) --+
```
⚙️ 关键点配置
1️⃣ 每个仓库的 GitHub Actions

（例子：a-service 仓库）
```
name: Build and Deploy A Service

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Build jar
        run: mvn clean package -DskipTests

      - name: Build Docker image
        run: docker build -t your-dockerhub-user/a-service:latest .

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_TOKEN }}

      - name: Push image
        run: docker push your-dockerhub-user/a-service:latest
```
2️⃣ 服务器 docker-compose.yml

放在 /root/app/docker-compose.yml：
```
version: "3.9"

services:
  a-service:
    image: your-dockerhub-user/a-service:latest
    restart: always
    ports:
      - "8081:8080"
    networks:
      - backend

  b-service:
    image: your-dockerhub-user/b-service:latest
    restart: always
    ports:
      - "8082:8080"
    networks:
      - backend

  c-service:
    image: your-dockerhub-user/c-service:latest
    restart: always
    ports:
      - "8083:8080"
    networks:
      - backend

  mysql:
    image: mysql:8
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpwd
    ports:
      - "3306:3306"
    networks:
      - backend

  redis:
    image: redis:7
    restart: always
    ports:
      - "6379:6379"
    networks:
      - backend

  watchtower:
    image: containrrr/watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --cleanup --interval 30  # 每30秒检查一次更新
    networks:
      - backend

networks:
  backend:
    driver: bridge
```
3️⃣ 服务之间互相调用

由于都在同一个 backend 网络里：

a-service 可以直接调用 http://b-service:8080/...

b-service 可以直接调用 http://c-service:8080/...

c-service 可以直接调用 http://mysql:3306 / redis:6379

不需要写 localhost 或者宿主机 IP。

🚀 工作流程

你 push 代码到 a-service 仓库

GitHub Actions 打包 jar → 构建 Docker 镜像 → push 到 Docker Hub

VPS 上的 watchtower 检测到 a-service:latest 有更新 → 自动拉取并替换容器

其他服务不受影响，继续运行

代码更新后，全链路自动完成 CI/CD + 自动部署

👉 总结：

✅ 多仓库 → 各自 push 触发 CI/CD

✅ Docker Hub 统一存储镜像

✅ watchtower 自动拉取更新

✅ docker-compose 保证服务互联

这样就是一个简化版的 微服务 CI/CD 自动部署体系。