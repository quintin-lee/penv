# python venv 管理

## 1. 使用命令

```shell
Usage: /usr/local/bin/penv cmd [params] 
Commands:
  create     - Creates a new virtual environment.
  list       - Lists all virtual environment.
  remove     - Removes a virtual environment.
  activate   - Activates a virtual environment.
  show       - Show active virtual environments.
  deactivate - Deactivates the current virtual environment.
  clean      - Deactivates all virtual environment.
  help       - Displays this help message.
```

## 2. archlinux/manjaro 打包

```shell
git clone https://github.com/quintin-lee/penv.git

tar zcvf penv.tar.gz penv scripts

make -si
```

## 3. deb 打包

```shell
# 执行过程中需要输入 sudo 密码
bash tools/make_deb.sh
```
