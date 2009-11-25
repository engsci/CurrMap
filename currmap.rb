require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'
require 'orm'

configure do
  $server = Couch::Server.new('localhost', 5984)
  $all_courses_view = "/currmap/_design/testing/_view/Courses"
end

helpers do
  def get_by_id(id)
    JSON.parse($server.get("/currmap/#{id}").body)
  end
  
  def get_all_courses
    JSON.parse($server.get($all_courses_view).body)["rows"]
  end
  
  def display(template, *args)
    haml template, :layout => !request.xhr?, *args
  end
end

get '/' do 
  display :index
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8' 
    sass :"stylesheets/#{params[:name]}"
end

get '/courses' do
  @courses = get_all_courses
  display :courses
end

get '/course/:code' do
  @course = Course.new params[:code]
  display :course
end

get '/prof/:name' do
  @prof = Staff.new params[:name]
  display :prof
end
