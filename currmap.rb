require 'sinatra'
require 'haml'
require 'sass'
require 'couch'
require 'json'
require 'ferret'
include Ferret

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
    haml(template, :layout => !request.xhr?)#, *args
  end
  
  def shorten(source, length)
    if source.length > length
      return "<span title=\""+source+"\">"+source[0..length]+"...</span>"
    else
      return source
    end
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

post '/search' do
  @user_query = params[:query]
  
  @searcher = Search::Searcher.new('ferret')
  @index = Index::Index.new(:path => 'ferret', :analyzer => Analysis::WhiteSpaceAnalyzer.new)
  
  field = :class
  @results = []
  query = Search::FuzzyQuery.new(field, @user_query, :prefix_length => 2)
  @searcher.search_each(query) do |id, score|
    @results << @index[id].load
  end
  display :search
end

get '/:class/:id' do
  @object = params[:class].capitalize.to_class.new params[:id]
  display params[:class].to_sym
end

get '/:class' do
  if Object.constants.member? params[:class].chop.capitalize
    @collection = params[:class].chop.capitalize.to_class.get_all
    display params[:class].to_sym
  end
end
