[TOC]

web前端

1.html

1.1head中可用的标签

页面的配置信息

```html
<html>
        <!-- 这是一个注释，注释的快捷键是ctrl+shift+/-->
        <!--
                head标签中：放入：页面的配置信息
        -->
        <head>
                <!--页面标题-->
                <title>百度一下，你就知道</title>
                <!--设置页面的编码，防止乱码现象
                        利用meta标签，
                        charset="utf-8" 这是属性，以键值对的形式给出 
                -->
                <meta charset="utf-8" /><!--简写-->
                <meta name="author" content="msb;213412@qq.com" />
                <!--设置页面搜索的关键字-->
                <meta name="keywords" content="马士兵教育;线上培训;架构师课程" />
                <!--页面描述-->
                <meta name="description" content="马士兵教育详情页" />
                <!--link标签引入外部资源-->
                <link rel="shortcut icon" href="https://www.baidu.com/favicon.ico" type="image/x-icon" />
        </head>
        <!--
                body标签中：放入：页面展示的内容
        -->
        <body>
                this is a html..你好
        </body>
</html>
```

