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

