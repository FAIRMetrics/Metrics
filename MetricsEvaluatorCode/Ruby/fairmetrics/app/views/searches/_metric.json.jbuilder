root_url = "http://linkeddata.systems:3000/metrics/"
metrics_url = "https://purl.org/fair-metrics/"

json.id metric_url(metric, format: :json)
json.extract! metric, :name, :creator, :email, :smarturl, :created_at, :updated_at

json.principle metrics_url + metric.principle.to_s
