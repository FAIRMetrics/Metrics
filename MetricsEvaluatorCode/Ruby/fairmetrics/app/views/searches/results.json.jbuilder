json.set! 'title', "Search Results"
json.set! 'description', "Your search results, separated into matching 'metrics' and 'collections'"

json.set! 'metrics' do
	json.array! @metrics.each do |metric|
		json.partial! "searches/metric", metric: metric
	end
end

json.set! 'collections' do
	json.array! @collections.each do |collection|
		json.partial! "searches/collection", coll: collection
	end
end

