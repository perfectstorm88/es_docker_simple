elasticsearch简单的安装部署、关键参数、增加密码、测试等功能

# 最简单集群的docker安装

参见官网[Install Elasticsearch with Docker](
https://www.elastic.co/guide/en/elasticsearch/reference/6.6/docker.html)

- 1、根据样例直接启动集群
- 2、检查启动状态
```
curl http://127.0.0.1:9200/_cat/health
```

## 最基础配置参数
第一个节点es01(主节点)
```yaml
  - cluster.name=docker-cluster #集群名称
  - bootstrap.memory_lock=true  # 关键参数，锁定内存，禁止swaping，提高效率
  - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
```
第二给节点es02(从节点)
```yaml
  - cluster.name=docker-cluster  #集群名称
  - bootstrap.memory_lock=true
  - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
  - "discovery.zen.ping.unicast.hosts=es02" # 静态设置主机列表
```

# 设置用户名密码

## 通过手工方式设置
参见：[ElasticSearch设置用户名密码访问](https://juejin.im/post/5c9c58fa5188250ef95d8b3c)
可以通过手工方式用户名密码访问

## 设置用户名密码的功能集成到docker-compose中
结合[Encrypting communications in an Elasticsearch Docker Container](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/configuring-tls-docker.html)中的部分配置参数，在docker-compose.yml中每个es节点的环境增加下列参数也可以完成此功能
```
environment:
  - ELASTIC_PASSWORD=123456  # 设置密码
  - xpack.license.self_generated.type=trial  # 自动生成并应用启动trial license，以便启用安全功能
  - xpack.security.enabled=true  # 开启x-pack验证
```

设置完密码后的访问方式为：
```
curl  -u elastic:elastic http://localhost:9200
```

# 辅助功能-docker-compose的健康检查

- 1、给es01主节点，增加healthcheck项，执行curl命令`curl  -u elastic:123456 http://localhost:9200` 检查节点是否正常
- 2、增加wait_until_ready服务，当服务启动完成后才退出（但是service_healthy在docker-compose 3版本中已经不再支持,而且在swam模式会被忽略）


# 安装es插件

以[Lucene IK analyzer 分词](https://github.com/medcl/elasticsearch-analysis-ik)插件为例:支持两个安装方式，一定要找到对应的安装包：

- 下载zip包，直接解压到plugins目录
- 使用elasticsearch-plugin命令安装

下载zip包的执行命令

## download.sh下载zip包的执行命令
```shell
mkdir plugins
wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.6.2/elasticsearch-analysis-ik-6.6.2.zip
unzip elasticsearch-analysis-ik-6.6.2.zip -d ./plugins/ik
```
## 验证插件
执行脚本`test_ik6.x.sh`

# 使用kibana
参照 [kibana使用.md](./kibana使用.md)