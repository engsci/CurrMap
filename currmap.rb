require 'rubygems'
require 'compass'

require 'sinatra'
require 'lib/render_partial'

require 'haml'
require 'sass'

require 'couch'
require 'json'
require 'ferret'
require 'error_handling'
require 'active_support' # For singularize

include Ferret

# Configure Compass
configure do
  Compass.configuration.parse(File.join(Sinatra::Application.root, 'config.rb'))
  $server = Couch::Server.new('localhost', 5984)
  $db = 'currmap'
end

Dir["./models/*.rb"].each { |file| require file}

class String
  def to_class
    Object.const_get self
  end
  def pluralize
    if self.downcase == "staff"
      return self
    else
      return self + "s"
    end
  end
end

error CouchConnectFailure do
  'Error connecting to CouchDB server, please try again'
  haml :error_page
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
  haml :index
  #haml :index, :locals => {:sidebar => :'_breadcrumb' }
  # haml :index, {:layout => :'layouts/blah'}
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8' 
  sass :"stylesheets/#{params[:name]}", Compass.sass_engine_options
end

get '/courses' do
  @collection = Course.get_all
  @collection = @collection.sort_by { |x| [x.year,x.semester,x.name]}
  params[:class] = "courses"
  @title = params[:class].capitalize
  display :courses
end

get '/search' do
  @user_query = params[:query].chomp.downcase
  
  params[:class] = params[:scope] = 'all'
  
  #@searcher = Search::Searcher.new('ferret')
  @index = Index::Index.new(:path => 'ferret', :analyzer => Analysis::StandardAnalyzer.new)
  
  field = :content
  @results = []
  query = Search::MultiTermQuery.new(field, :max_term => 10)
  @user_query.split(' ',10).each do |s|
    query << s
  end
  query.add_term(@user_query, 5)
  
  @index.search_each(query) do |id, score|
#    @results[@index[id]["class"]] = [] unless @results[@index[id]["class"]]
 #   @results[@index[id]["class"]] 
     @results << {
      :id => @index[id]["id"], 
      :name => @index[id]["name"],
      :model => @index[id]["class"],
      :highlight => @index.highlight(query, id, :field => field, :num_excerpts => 5, :excerpt_length => 20, :pre_tag => "<strong>", :post_tag => "</strong>")
      } if params[:scope] == "all" or params[:scope].singularize == @index[id]["class"].downcase
  end
  @title = params[:query] + " : " + params[:scope] + " : Search"
  display :search, :layouts => :'layouts/search'
end

get '/results' do
  haml :results, :locals => {:sidebar => :_search_options}
end

get '/:class/:id' do
  @object = params[:class].capitalize.to_class.new params[:id]
  @title = (@object.name || @object._id).to_s + " : " + params[:class].capitalize.pluralize
  display params[:class].to_sym
end

get '/:class' do
  if Object.constants.map(&:to_s).member? params[:class].singularize.capitalize
    @collection = params[:class].singularize.capitalize.to_class.get_all
    @title = params[:class].capitalize
    display params[:class].pluralize.to_sym
  else
    haml params[:class].to_sym
  end
end
