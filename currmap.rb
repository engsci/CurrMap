require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'

configure do
  $server = Couch::Server.new('localhost', 5984)
end

helpers do
  def get_by_id(id)
    JSON.parse($server.get("/currmap/#{id}").body)
  end
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
  @course = get_by_id params[:code]
  haml :course
end

get '/prof/:name' do
  @prof = get_by_id params[:name]
  haml :prof
end
