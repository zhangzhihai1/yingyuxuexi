# 1.内嵌

```powershell
my_microservice/
├── main.go                 # 程序入口，初始化和启动服务
├── go.mod                  # Go 模块文件
├── go.sum                  # Go 模块校验和
├── internal/               # 内部包，不对外暴露
│   ├── metrics/            # 存放所有与指标相关的代码
│   │   ├── collector.go    # 自定义 Collector (如 AppHealthCollector)
│   │   └── registry.go     # 注册表和标准指标定义与初始化
│   └── handler/            # 存放业务逻辑处理函数
│       ├── car.go          # 车辆服务的处理函数和中间件
│       └── shop.go         # 商城服务的处理函数和中间件
└── routes/                 # 存放路由定义
    └── routes.go           # 路由组和中间件的绑定
```



```go
// main.go
package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/collectors" // 导入 collectors 包以使用默认收集器
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// ================================
// 1. 车辆服务 (Car Service) - 指标定义与初始化
// ================================

// carRegistry: 为车辆服务创建一个独立的 Prometheus 注册表。
// 这样可以将车辆服务的指标与商城服务或其他服务的指标隔离开来。
var carRegistry = prometheus.NewRegistry()

// carRequestsTotal: Counter 类型，用于记录车辆服务接收到的 HTTP 请求总数。
// 标签 (Labels) "code", "method", "endpoint" 用于区分不同的请求。
// - code: HTTP 状态码 (如 "200", "500")
// - method: HTTP 方法 (如 "GET", "POST")
// - endpoint: 请求的 API 路径 (如 "/api/car/random")
var carRequestsTotal = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "car_http_requests_total",
		Help: "Total number of HTTP requests by status code, method, and endpoint for car service.",
	},
	[]string{"code", "method", "endpoint"},
)

// carActiveRequests: Gauge 类型，用于记录车辆服务当前正在进行的活跃请求数。
// Gauge 可以上下浮动，非常适合表示“当前数量”。
var carActiveRequests = prometheus.NewGauge(
	prometheus.GaugeOpts{
		Name: "car_active_requests",
		Help: "Current number of active HTTP requests for car service.",
	},
)

// carRequestDuration: Histogram 类型，用于测量车辆服务 HTTP 请求的延迟分布。
// Histogram 将延迟划分为多个 bucket (例如 0.005s, 0.01s, 0.025s...)，可以快速统计百分位数。
// prometheus.DefBuckets 提供了一组默认的 bucket。
var carRequestDuration = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{
		Name:    "car_http_request_duration_seconds_histogram",
		Help:    "Histogram of latencies for HTTP requests for car service.",
		Buckets: prometheus.DefBuckets, // 使用默认的 bucket 划分
	},
	[]string{"method", "endpoint"},
)

// carRequestLatency: Summary 类型，用于测量车辆服务 HTTP 请求的延迟分位数。
// Summary 可以直接配置需要计算的分位数 (如 0.5, 0.9, 0.99) 及其误差。
// - 0.5: 中位数延迟
// - 0.9: 90% 分位数延迟
// - 0.99: 99% 分位数延迟
var carRequestLatency = prometheus.NewSummaryVec(
	prometheus.SummaryOpts{
		Name:       "car_http_request_latency_seconds",
		Help:       "Summary of HTTP request latencies in seconds for car service.",
		Objectives: map[float64]float64{0.5: 0.05, 0.9: 0.01, 0.99: 0.001}, // 配置分位数和允许的误差
	},
	[]string{"method", "endpoint"},
)

// carPrometheusMiddleware: 车辆服务专用的 Prometheus 中间件。
// 它负责在请求处理前后更新车辆服务的指标。
func carPrometheusMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 记录请求开始时间
		start := time.Now()
		// 获取请求的路径和方法
		path := c.FullPath()
		method := c.Request.Method

		// 请求开始前：活跃请求数 +1
		carActiveRequests.Inc()

		// 执行后续的处理链（即实际的业务逻辑）
		c.Next()

		// 请求结束后：活跃请求数 -1
		carActiveRequests.Dec()

		// 获取最终的 HTTP 状态码
		status := c.Writer.Status()
		// 计算请求处理耗时（秒）
		duration := time.Since(start).Seconds()

		// 更新 Counter 指标：请求总数
		carRequestsTotal.WithLabelValues(fmt.Sprintf("%d", status), method, path).Inc()
		// 更新 Histogram 指标：延迟分布
		carRequestDuration.WithLabelValues(method, path).Observe(duration)
		// 更新 Summary 指标：延迟分位数
		carRequestLatency.WithLabelValues(method, path).Observe(duration)
	}
}

// carRandomHandler: 模拟车辆服务的处理逻辑。
// 它会随机成功或失败，并产生随机延迟。
func carRandomHandler(c *gin.Context) {
	// 模拟随机延迟 (100ms - 600ms)
	delay := time.Duration(rand.Intn(500)+100) * time.Millisecond
	time.Sleep(delay)

	// 70% 概率返回成功 (HTTP 200)，30% 概率返回失败 (HTTP 500)
	if rand.Float32() < 0.7 {
		c.JSON(http.StatusOK, gin.H{
			"service": "car",
			"message": "Car request succeeded",
			"delay":   delay.String(),
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{
			"service": "car",
			"error":   "Car request failed",
			"delay":   delay.String(),
		})
	}
}

// ================================
// 2. 商城服务 (Shop Service) - 指标定义与初始化
// ================================

// shopRegistry: 为商城服务创建一个独立的 Prometheus 注册表。
var shopRegistry = prometheus.NewRegistry()

// shopRequestsTotal: Counter 类型，用于记录商城服务接收到的 HTTP 请求总数。
var shopRequestsTotal = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "shop_http_requests_total",
		Help: "Total number of HTTP requests by status code, method, and endpoint for shop service.",
	},
	[]string{"code", "method", "endpoint"},
)

// shopActiveRequests: Gauge 类型，用于记录商城服务当前正在进行的活跃请求数。
var shopActiveRequests = prometheus.NewGauge(
	prometheus.GaugeOpts{
		Name: "shop_active_requests",
		Help: "Current number of active HTTP requests for shop service.",
	},
)

// shopRequestDuration: Histogram 类型，用于测量商城服务 HTTP 请求的延迟分布。
var shopRequestDuration = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{
		Name:    "shop_http_request_duration_seconds_histogram",
		Help:    "Histogram of latencies for HTTP requests for shop service.",
		Buckets: prometheus.DefBuckets,
	},
	[]string{"method", "endpoint"},
)

// shopRequestLatency: Summary 类型，用于测量商城服务 HTTP 请求的延迟分位数。
var shopRequestLatency = prometheus.NewSummaryVec(
	prometheus.SummaryOpts{
		Name:       "shop_http_request_latency_seconds",
		Help:       "Summary of HTTP request latencies in seconds for shop service.",
		Objectives: map[float64]float64{0.5: 0.05, 0.9: 0.01, 0.99: 0.001},
	},
	[]string{"method", "endpoint"},
)

// shopPrometheusMiddleware: 商城服务专用的 Prometheus 中间件。
// 功能与 carPrometheusMiddleware 类似，但操作的是商城服务的指标。
func shopPrometheusMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.FullPath()
		method := c.Request.Method

		shopActiveRequests.Inc()
		c.Next()
		status := c.Writer.Status()
		duration := time.Since(start).Seconds()
		shopActiveRequests.Dec()

		shopRequestsTotal.WithLabelValues(fmt.Sprintf("%d", status), method, path).Inc()
		shopRequestDuration.WithLabelValues(method, path).Observe(duration)
		shopRequestLatency.WithLabelValues(method, path).Observe(duration)
	}
}

// shopRandomHandler: 模拟商城服务的处理逻辑。
// 它会随机成功或失败，并产生随机延迟。
func shopRandomHandler(c *gin.Context) {
	// 模拟随机延迟 (100ms - 600ms)
	delay := time.Duration(rand.Intn(500)+100) * time.Millisecond
	time.Sleep(delay)

	// 80% 概率返回成功 (HTTP 200)，20% 概率返回失败 (HTTP 500)
	if rand.Float32() < 0.8 {
		c.JSON(http.StatusOK, gin.H{
			"service": "shop",
			"message": "Shop request succeeded",
			"delay":   delay.String(),
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{
			"service": "shop",
			"error":   "Shop request failed",
			"delay":   delay.String(),
		})
	}
}

// ================================
// 3. 自定义 Collector: AppHealthCollector
// ================================
// AppHealthCollector 是一个自定义的 Prometheus Collector，用于暴露一个模拟的应用健康分数。

// AppHealthCollector 结构体
// 我们可以在这里存储 Collector 需要的任何状态或配置。
// 为了演示并发安全，我们使用 sync.Mutex。
type AppHealthCollector struct {
	// desc 是指标的描述符，在 Describe 方法中使用。
	// 它描述了指标的名称、帮助信息和标签。
	desc *prometheus.Desc
	// mu 用于保护内部状态，使其并发安全。
	mu sync.Mutex
	// lastCalculated 用于存储上次计算健康分数的时间，模拟计算成本。
	lastCalculated time.Time
	// cachedScore 用于缓存上次计算的分数，避免每次收集都重新计算。
	cachedScore float64
}

// NewAppHealthCollector 创建并返回一个新的 AppHealthCollector 实例。
func NewAppHealthCollector() *AppHealthCollector {
	return &AppHealthCollector{
		// prometheus.NewDesc 用于创建指标描述符。
		// 参数：指标名, 帮助信息, 标签键列表, 常量标签
		desc: prometheus.NewDesc(
			"app_health_score",                     // 指标名称
			"A custom health score for the application (0-100).", // 帮助信息
			nil,        // 标签键列表 (此指标无标签)
			nil,        // 常量标签 (无)
		),
		lastCalculated: time.Now().Add(-10 * time.Minute), // 初始化为很久以前，确保第一次调用会计算
		cachedScore:    0,
	}
}

// Describe 方法将该 Collector 提供的所有指标的描述符发送到传入的通道。
// 这是 prometheus.Collector 接口要求的方法。
func (c *AppHealthCollector) Describe(ch chan<- *prometheus.Desc) {
	// 发送我们唯一的指标描述符
	ch <- c.desc
}

// calculateHealthScore 是一个模拟的健康分数计算逻辑。
// 在实际应用中，这里可能会查询其他服务的状态、检查数据库连接、分析日志等。
func (c *AppHealthCollector) calculateHealthScore() float64 {
	// 模拟一个随时间变化且有一定随机性的分数
	// 例如：基础分数 80，随时间波动 +/- 10，再加一个随机扰动 +/- 5
	baseScore := 80.0
	timeFactor := 10.0 * (0.5 - (float64(time.Now().UnixNano()%1000000000) / 1000000000.0)) // -5 到 +5
	randomFactor := 5.0 * (0.5 - rand.Float64()) // -2.5 到 +2.5
	score := baseScore + timeFactor + randomFactor
	// 确保分数在 0-100 范围内
	if score < 0 {
		return 0
	}
	if score > 100 {
		return 100
	}
	return score
}

// Collect 方法是 Collector 的核心，它负责收集指标的实际值并发送到通道。
// 这是 prometheus.Collector 接口要求的方法。
func (c *AppHealthCollector) Collect(ch chan<- prometheus.Metric) {
	c.mu.Lock()
	defer c.mu.Unlock()

	// 模拟：每5秒才重新计算一次分数，否则使用缓存
	now := time.Now()
	if now.Sub(c.lastCalculated) > 5*time.Second {
		c.cachedScore = c.calculateHealthScore()
		c.lastCalculated = now
		// fmt.Printf("Recalculated health score: %.2f\n", c.cachedScore) // 可选：打印日志
	}

	// 使用 prometheus.MustNewConstMetric 创建一个常量指标 (因为我们每次计算一个值)
	// 参数：指标描述符, 指标类型, 指标值, 标签值 (此指标无标签，所以是空切片)
	metric := prometheus.MustNewConstMetric(
		c.desc,
		prometheus.GaugeValue, // 指标类型为 Gauge
		c.cachedScore,         // 指标值
	)

	// 将创建的指标发送到通道
	ch <- metric
}

// ================================
// 4. 初始化阶段 (init 函数)
// ================================
// init 函数在程序启动时自动执行，用于将指标注册到各自的注册表中。
func init() {
	// --- 注册车辆服务的所有指标到 carRegistry ---
	// MustRegister 会在注册失败时 panic，确保程序启动时配置正确。
	carRegistry.MustRegister(carRequestsTotal)
	carRegistry.MustRegister(carActiveRequests)
	carRegistry.MustRegister(carRequestDuration)
	carRegistry.MustRegister(carRequestLatency)

	// --- 注册商城服务的所有指标到 shopRegistry ---
	shopRegistry.MustRegister(shopRequestsTotal)
	shopRegistry.MustRegister(shopActiveRequests)
	shopRegistry.MustRegister(shopRequestDuration)
	shopRegistry.MustRegister(shopRequestLatency)

	// --- 注册默认的 Go 和 Process 收集器到 Prometheus 的全局默认注册表 ---
	// 这些收集器会自动暴露 Go 运行时和进程级别的指标，例如内存、GC、CPU 使用情况等。
	// prometheus.MustRegister 是向全局默认注册表 (prometheus.DefaultRegisterer) 注册的便捷方法。
	prometheus.MustRegister(collectors.NewGoCollector())          // 注册 Go 运行时指标收集器
	prometheus.MustRegister(collectors.NewProcessCollector(collectors.ProcessCollectorOpts{})) // 注册进程指标收集器
	// 可选：注册构建信息收集器
	prometheus.MustRegister(prometheus.NewBuildInfoCollector())

	// --- 注册我们自定义的 Collector ---
	// 将自定义的 AppHealthCollector 注册到全局默认注册表
	prometheus.MustRegister(NewAppHealthCollector())
}

// ================================
// 5. 主函数：启动服务并聚合指标
// ================================
func main() {
	// 使用 Gin 框架创建一个默认的路由引擎
	r := gin.Default()

	// --- 车辆服务路由组 ---
	// Group 方法可以将一组路由组织在一起，并可以应用通用的中间件。
	carGroup := r.Group("/api/car")
	// 为车辆服务组应用其专用的 Prometheus 中间件
	carGroup.Use(carPrometheusMiddleware())
	{
		// 在车辆服务组下注册具体的 API 路由
		carGroup.GET("/random", carRandomHandler)
		// 可以在此处添加更多车辆服务的接口，例如:
		// carGroup.GET("/status", carStatusHandler)
	}

	// --- 商城服务路由组 ---
	shopGroup := r.Group("/api/shop")
	// 为商城服务组应用其专用的 Prometheus 中间件
	shopGroup.Use(shopPrometheusMiddleware())
	{
		// 在商城服务组下注册具体的 API 路由
		shopGroup.GET("/random", shopRandomHandler)
		// 可以在此处添加更多商城服务的接口，例如:
		// shopGroup.GET("/items", shopItemsHandler)
	}

	// --- 聚合所有需要暴露的注册表 ---
	// prometheus.Gatherers 是一个 Gatherer 接口的切片，可以聚合多个注册表。
	// 我们需要聚合：
	// 1. prometheus.DefaultGatherer: 包含默认注册表中的指标 (Go/Process 收集器 + 自定义 Collector)
	// 2. carRegistry: 包含车辆服务的指标
	// 3. shopRegistry: 包含商城服务的指标
	gatherers := prometheus.Gatherers{
		prometheus.DefaultGatherer, // 添加默认收集器的 Gatherer
		carRegistry,                // 添加车辆服务注册表
		shopRegistry,               // 添加商城服务注册表
	}

	// promhttp.HandlerFor 创建一个 HTTP Handler，它能从指定的 Gatherer 获取指标。
	// HandlerOpts 可以配置 handler 的行为，例如启用 OpenMetrics 格式。
	registryHandler := promhttp.HandlerFor(gatherers, promhttp.HandlerOpts{})

	// 将聚合后的指标暴露在 /metrics 路径上。
	// gin.WrapH 将标准库的 http.Handler 转换为 Gin 的 HandlerFunc。
	r.GET("/metrics", gin.WrapH(registryHandler))

	// --- 启动服务 ---
	// 打印启动信息到控制台
	println("Server started at http://localhost:8080")
	println("Test Car Service:   curl http://localhost:8080/api/car/random")
	println("Test Shop Service:  curl http://localhost:8080/api/shop/random")
	println("View All Metrics:   http://localhost:8080/metrics")

	// 启动 HTTP 服务器，监听在 :8080 端口
	r.Run(":8080")
}

```

# 2.独立程序

```powershell
my_project/
├── go.mod
├── go.sum
├── app/                          # 模拟的主应用
│   └── main.go                   # 应用逻辑，不包含 Prometheus 客户端
├── exporter/                     # 独立的 Prometheus Exporter
│   ├── main.go                   # Exporter 程序入口
│   ├── internal/
│   │   ├── collector/            # 存放自定义 Collector
│   │   │   ├── collector.go      # Collector 接口和基础结构
│   │   │   ├── car_collector.go  # 收集车辆服务指标的 Collector
│   │   │   └── shop_collector.go # 收集商城服务指标的 Collector
│   │   └── metrics/
│   │       └── registry.go       # Exporter 内部的注册表 (可选，或直接用默认)
│   └── config/                   # 配置文件 (可选)
│       └── config.go             # 加载配置 (如目标应用地址)
```

```powershell
my_project/
├── go.mod
├── go.sum
├── README.md
├── cmd/                    # 存放所有可执行程序的主入口
│   ├── app/                # app 程序
│   │   └── main.go         # app 的入口文件
│   └── exporter/           # exporter 程序
│       └── main.go         # exporter 的入口文件
├── internal/               # 内部共享包 (可选)
│   ├── applogic/           # app 可能的内部业务逻辑 (如果有的话)
│   └── exporter/           # exporter 的内部包
│       ├── collector/
│       │   ├── collector.go
│       │   ├── car_collector.go
│       │   └── shop_collector.go
│       └── metrics/        # 如果需要
├── configs/                # 配置文件目录 (可选)
└── deployments/            # 部署相关文件，如 Dockerfile, k8s manifests (可选)
```

