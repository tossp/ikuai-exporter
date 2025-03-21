package main

import (
	"log"
	"net/http"

	"github.com/tossp/ikuai"
	"github.com/tossp/ikuai-exporter/pkg"

	"github.com/alexflint/go-arg"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type Config struct {
	Ikuai         string `arg:"env:IK_URL" help:"iKuai URL" default:"http://10.0.1.253"`
	IkuaiUsername string `arg:"env:IK_USER" help:"iKuai username" default:"test"`
	IkuaiPassword string `arg:"env:IK_PWD" help:"iKuai password" default:"test123"`
	Debug         bool   `arg:"env:DEBUG" help:"iKuai 开启 debug 日志" default:"false"`
	InsecureSkip  bool   `arg:"env:SKIP_TLS_VERIFY" help:"是否跳过 iKuai 证书验证" default:"true"`
	Listen        string `arg:"env:LISTEN" help:"监听地址和端口" default:":9090"`
}

var (
	projectName  string
	gitVersion   string
	buildVersion string
	buildTime    string
	buildUser    string
	version      string
)

func main() {
	log.Println("iKuai Exporter", version)
	config := &Config{}
	arg.MustParse(config)

	if config.Debug {
		log.Println("iKuai 开启 debug 日志")
		log.Println("Project name:", projectName)
		log.Println("Git version:", gitVersion)
		log.Println("Build version:", buildVersion)
		log.Println("Build time:", buildTime)
		log.Println("Build user:", buildUser)
	}

	i := ikuai.NewIKuai(config.Ikuai, config.IkuaiUsername, config.IkuaiPassword, config.InsecureSkip, true)

	if config.Debug {
		i.Debug()
	}

	registry := prometheus.NewRegistry()

	registry.MustRegister(pkg.NewIKuaiExporter(i))

	http.Handle("/metrics", promhttp.HandlerFor(registry, promhttp.HandlerOpts{Registry: registry}))

	log.Printf("exporter %v started at %s", version, config.Listen)

	log.Fatal(http.ListenAndServe(config.Listen, nil))
}
