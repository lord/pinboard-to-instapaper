require 'faraday'
require 'pinboard_api'
require 'io/console'

conn = Faraday.new(:url => 'https://www.instapaper.com:443') do |faraday|
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

def post_to_instapaper(conn, url, username, password)
  request = conn.post do |req|
    req.url '/api/add'
    req.params['username'] = username
    req.params['password'] = password
    req.params['url'] = url
  end
  if request.status != 201
    raise "Instapaper failed to authorize!"
  end
end

puts "Enter your Pinboard API token:"
PinboardApi.auth_token = gets.strip

puts "Enter the Pinboard tag to import:"
tag_to_import = gets.strip

puts "Enter your Instapaper username:"
ip_username = gets.strip

puts "Enter your Instapaper password:"
ip_password = STDIN.noecho(&:gets)

PinboardApi::Post.all(tag: tag_to_import).each do |post|
  post_to_instapaper(conn, post.url, ip_username, ip_password)
  puts "Importing #{post.url} to Instapaper"
end

puts "Done!"
