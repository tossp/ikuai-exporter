# IKuai Prometheus Exporter


![grafana](https://raw.githubusercontent.com/tossp/ikuai-exporter/refs/heads/main/docs/images/grafana.png "grafana")

### 部署

部署下面的容器，配置容器环境变量，设置爱快地址和登录密码。

```shell
docker pull tossp/ikuai-exporter:1.2
```

登录的帐号密码建议创建一个只读用户使用。

| 变量名     | 说明     |
|:------- |:------ |
| IK_URL  | 爱快地址   |
| IK_USER | 爱快登录用户 |
| IK_PWD  | 爱快登录密码 |
| LISTEN  | 监听地址    |

2k 分辨率
1. https://grafana.com/grafana/dashboards/22756
1. https://raw.githubusercontent.com/tossp/ikuai-exporter/refs/heads/main/examples/grafana/2k.json

### 开发调试
```shell
make HOST_OPT="--ikuai=http://192.168.9.1 --ikuaiusername=test --ikuaipassword=test123456 --debug"
```


### 致谢

[jakeslee/ikuai-exporter](https://github.com/jakeslee/ikuai-exporter)

[NERVEbing/ikuai-exporter](https://github.com/NERVEbing/ikuai-exporter)

### License

[License MIT](LICENSE)
