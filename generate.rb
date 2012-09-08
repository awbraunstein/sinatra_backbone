# -*- coding: utf-8 -*-


if ARGV.length < 1
  p 'Usage: MODEL_NAME attribute:type attribute:type ...'
  p 'Types are: String, Integer, Text, etc.'
  exit
end
flags = []
arguments = []

ARGV.each do |arg|
  if arg.match(/^--/)
    flags.push(arg)
  else
    arguments.push(arg)
  end

end

model_name = arguments[0].capitalize
attributes = {}
(1...arguments.length).each do |i|
  arg = arguments[i]
  name, type = arg.split(':')
  attributes[name] = type
end

# Generate the Datamapper migration code
model_string = "
class #{model_name}
  include DataMapper::Resource

  property :id, Serial
"
attributes.each do |name, type|
  model_string += "  property :#{name}, #{type.capitalize!}\n"
end

model_string += "end\n"

puts "====FILE ./db/migrations/#{model_name}.rb====="
puts model_string
puts "=============================================="
unless flags.include? "--dry"
  migration = File.new("./db/migrations/#{model_name}.rb", "w")
  migration.write(model_string)
  migration.close
end

# Generate the boilerplate rest code for the model

# Get
get_string = %&
get "/#{model_name.downcase}" do
  #{model_name}.all.to_json
end&

# Post
post_string = %&
post "/#{model_name.downcase}" do

  # Create a new post
  data = JSON.parse request.body.read

  p = #{model_name}.create(&

attributes.keys.each_with_index do |name, i|
  post_string += ":#{name} => data['#{name}']"
  if i+1 < attributes.keys.length
    post_string += ", "
  end
end
post_string += ")
  # return the newly created object in json
  p.attributes.to_json
end"

# Get (Individual item)
get_string_individual = %&
get "/#{model_name.downcase}/:id" do
  #{model_name}.find(params[:id]).to_json
end&

# Put
put_string = %&
put "/#{model_name.downcase}/:id" do
  obj = #{model_name}.find(params[:id])
  data = JSON.parse request.body.read
  obj.update! data
  obj.attributes.to_json
end&
# Delete
delete_string = %&
delete "/#{model_name.downcase}/:id" do
  obj = #{model_name}.find(params[:id])
  obj.destroy
end&

rest_string = get_string + "\n" + post_string + "\n" + get_string_individual + "\n" + put_string + "\n" + delete_string
puts "====FILE ./rest/#{model_name}.rb====="
puts rest_string
puts "====================================="
unless flags.include? "--dry"
  rest_view = File.new("./rest/#{model_name}.rb", "w")
  rest_view.write(rest_string)
  rest_view.close
end


# TODO: Generate the boilerplate backbone code
