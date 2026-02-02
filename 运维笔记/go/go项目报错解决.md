### 1.swag初始化失败

go get -u github.com/swaggo/swag/cmd/swag

swag init

![image-20250703155004733](image-20250703155004733.png)

解决：

go install github.com/swaggo/swag/cmd/swag@latest

从 **Go 1.17 开始**，`go get` 不再用于安装可执行命令（即 CLI 工具）。