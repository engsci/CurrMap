require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'

Dir["./models/*.rb"].each { |file| require file}

class String
  def to_class
    Object.const_get self
  end
end

configure do
  $server = Couch::Server.new('localhost', 5984)
  $db = 'currmap'
end

helpers do
  def get_by_id(id)
    JSON.parse($server.get("/#{$db}/#{id}").body)
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
  @collection = Course.get_all
  @collection = @collection.sort_by { |x| [x.year,x.semester,x.name]}
  display :courses
end

get '/:class/:id' do
  @object = Object.const_get(params[:class].capitalize).new params[:id]
  display params[:class].to_sym
end

get '/:class' do
  @collection= params[:class].chop.capitalize.to_class.get_all
  display params[:class].to_sym
end
