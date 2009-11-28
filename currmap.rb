require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'
Dir["./models/*.rb"].each { |file| require file}

configure do
  $server = Couch::Server.new('localhost', 5984)
  $all_courses_view = "/currmap/_design/testing/_view/Courses"
  $all_staff_view = "/currmap/_design/testing/_view/Staff"
  $all_resources_view = "/currmap/_design/testing/_view/Resources"
end

helpers do
  def get_by_id(id)
    JSON.parse($server.get("/currmap/#{id}").body)
  end
  
  def get_all_courses
    JSON.parse($server.get($all_courses_view).body)["rows"].map do |course|
      Course.new course["value"]
    end
  end
  
  def get_all_staff
    JSON.parse($server.get($all_staff_view).body)["rows"].map do |prof|
      Staff.new prof["value"]
    end
  end
  
  def get_all_resources
    JSON.parse($server.get($all_resources_view).body)["rows"].map do |res|
      Resource.new res["value"]
    end
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
  @courses = @courses.sort_by { |x| [x.year,x.semester,x.name]}
  display :courses
end

get '/staff' do
  @staff = get_all_staff
  display :staff
end

get '/resources' do
  @staff = get_all_resources
  display :resources
end

get '/resource/:id' do
  @resource = Resource.new params[:id]
  display :resource
end

get '/course/:code' do
  @course = Course.new params[:code]
  display :course
end

get '/prof/:name' do
  @prof = Staff.new params[:name]
  display :prof
end
