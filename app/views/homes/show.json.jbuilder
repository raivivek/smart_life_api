# 主页返回健身排名
json.fitness do
  json.today @today
  json.rank @rank
  json.step @step
end

# 新品上市模块
json.newer do
  json.url image_url ""
  json.end_time (Time.zone.now + 3.hour).strftime("%F %T")
end

# 限量销售模块
json.product do
  json.url image_url ""
end
