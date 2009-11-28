require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'

Dir["./models/*.rb"].each { |file| require file}

def get_view(view)
  return File.join("/", $db, "_design", $design_doc, "_view", view+"s")
end

configure do
  $server = Couch::Server.new('localhost', 5984)
  $db = 'currmap'
  $design_doc = 'testing'
end

helpers do
  def get_by_id(id)
    JSON.parse($server.get("/currmap/#{id}").body)
  end
  
  def get_all(target_class)
    Object.const_get(target_class).get_all
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
  @collection = get_all "Course"
  @collection = @collection.sort_by { |x| [x.year,x.semester,x.name]}
  display :courses
end

get '/:class/:id' do
  @object = Object.const_get(params[:class].capitalize).new params[:id]
  display params[:class].to_sym
end

get '/:class' do
  @collection= get_all params[:class].chop.capitalize
  display params[:class].to_sym
end
