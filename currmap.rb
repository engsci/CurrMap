require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'

configure do
  $server = Couch::Server.new('localhost', 5984)
end

get '/' do 
  haml :index
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8' 
    sass :"stylesheets/#{params[:name]}"
end

get '/courses' do
  @courses = JSON.parse($server.get("/currmap/_design/testing/_view/Courses").body)["rows"]
  haml :courses
end

get '/course/:code' do
  course = $server.get("/currmap/#{params[:code]}").body
  
end
