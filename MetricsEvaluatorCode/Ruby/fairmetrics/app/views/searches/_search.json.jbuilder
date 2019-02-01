

json.set! '$id', uri
json.set! '$schema', "http://json-schema.org/draft-07/schema#"
json.set! 'title', "Search Input"
json.set! 'description', "Your search interface has been created (See 'Location' header, or the $id component above).  Please POST a message following the JSON schema below to retrieve your search results"
json.set! 'required' do
	json.array! ["keywords"]
end
json.set! 'type', "object"
json.set! "properties" do
	json.set! "keywords" do
		json.set! "type", "string"
		json.set! "description", "Comma-delimited list of keywords to include in search."
		json.set! "minimum", "1"
		json.set! "maximum", "1"
	end
end
