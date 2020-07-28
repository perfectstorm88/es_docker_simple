# ES安装好后再安装Kibana就比较简单了

参见官网[Install Kibana with Dockeredit
](https://www.elastic.co/guide/en/kibana/current/docker.html)

```yaml
version: '2'
services:
  kibana:
    image: docker.elastic.co/kibana/kibana:6.6.2
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch.example.org
    volumes:
      - ./kibana.yml:/usr/share/kibana/config/kibana.yml
```

其中kibana.yml样例如下
```
elasticsearch.username: "elastic"
elasticsearch.password: "123456"
```

## kibana环境变量的配置说明

在Docker下，可以通过环境变量配置Kibana。当容器启动时，helper进程检查环境中是否有可以映射到Kibana命令行参数的变量。

为了与容器编排系统兼容，这些环境变量以大写字母书写，并用下划线作为单词分隔符。helper进程手将这些名称转换为有效的Kibana设置名称，例如：

| 环境变量  | kibana设置   |
|---|---|
| SERVER_NAME  |  server.name |
| ELASTICSEARCH_HOSTS  |  elasticsearch.hosts|
| ELASTICSEARCH_USERNAME  |  elasticsearch.username|
| ELASTICSEARCH_PASSWORD  |  elasticsearch.password|

# 简化后的配置文件样例
```yaml
services:
  kib01:
    image: kibana:6.6.2
    ports:
     - 5601:5601
    environment:
      ELASTICSEARCH_HOSTS: http://es01:9200
      ELASTICSEARCH_USERNAME: "elastic"
      ELASTICSEARCH_PASSWORD: "elastic"
```

# kibana使用

[kibana基础入门](https://www.elastic.co/guide/cn/kibana/current/getting-started.html)，包含下面几部分:

- 加载数据集,执行脚本如下，elastic.co可能需要翻墙下载

```shell
# 定义变量
AUTH=" -u elastic:elastic"
URL="http://localhost:9200"
# 下载数据集
wget https://download.elastic.co/demos/kibana/gettingstarted/shakespeare_6.0.json
wget https://download.elastic.co/demos/kibana/gettingstarted/accounts.zip
wget https://download.elastic.co/demos/kibana/gettingstarted/logs.jsonl.gz
# 解压
unzip accounts.zip
gunzip logs.jsonl.gz

# 为字段设置映射关系，把索引中的文档按逻辑分组并指定了字段的属性，比如字段的可搜索性或者该字段是否是tokenized ，或分解成单独的单词
# 建立一个莎士比亚数据集的映射
curl $AUTH -XPUT "$URL/shakespeare?pretty" -H 'Content-Type: application/json' -d'
{
 "mappings": {
  "doc": {
   "properties": {
    "speaker": {"type": "keyword"},
    "play_name": {"type": "keyword"},
    "line_id": {"type": "integer"},
    "speech_number": {"type": "integer"}
   }
  }
 }
}
'
# 为日志建立 geo_point 映射
curl $AUTH -XPUT "$URL/logstash-2015.05.18?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
'
curl $AUTH -XPUT "$URL/logstash-2015.05.19?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
'
curl $AUTH -XPUT "$URL/logstash-2015.05.20?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
'
# 加载数据集
curl -H 'Content-Type: application/x-ndjson' $AUTH -XPOST "$URL/bank/account/_bulk?pretty" --data-binary @accounts.json
curl -H 'Content-Type: application/x-ndjson' $AUTH -XPOST "$URL/shakespeare/doc/_bulk?pretty" --data-binary @shakespeare_6.0.json
curl -H 'Content-Type: application/x-ndjson' $AUTH -XPOST "$URL/_bulk?pretty" --data-binary @logs.jsonl

# 使用下面的命令来验证加载是否成功：
curl $AUTH -X GET "$URL/_cat/indices?v&pretty"
```

- [定义自己的索引模式](https://www.elastic.co/guide/cn/kibana/current/tutorial-define-index.html)
  - 原理：先过滤index，然后选择某个index，执行语句查询
    - 例如：先通过ba* 过滤index为bank的数据，然后执行’account_number:<100 AND balance:>47500’ 筛选出关心的数据
  - 显示方面：默认显示json格式，也可以选择字段，以表格方式展示
  - 注意，如果时间格式的话，要注意默认只有15分钟，要选择合适的时间过滤范围
- [可视化数据](https://www.elastic.co/guide/cn/kibana/current/tutorial-visualizing.html)
  - 选择视图
  - 进行Split Slices 桶类别，定义区间桶
  - 也可以添加子桶， sub-buckets 
  - 也可以使用地图来可视化日志样本数据集中的地理标识信息
- [使用仪表板汇总数据](https://www.elastic.co/guide/cn/kibana/current/tutorial-dashboard.html)

