require 'rubygems'
require 'compass'

require 'sinatra'
require 'lib/render_partial'

require 'haml'
require 'sass'

require 'couch'
require 'lib/tok'
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
  auth_info = YAML.load_file((File.join(Sinatra::Application.root, 'settings.yml')))
  set :username, auth_info['tok-interface-un']
  set :password, auth_info['tok-interface-pw']
  $yggdrasil = TreeOfKnowledge::Client.new('localhost', 8080, '/tok-ruby/',
                                           auth_info['tok-username'], auth_info['tok-password'])
end

Dir["./models/*.rb"].each { |file| require file}

class String
  def to_class
    Object.const_get self
  end
end

error CouchConnectFailure do
  'Error connecting to CouchDB server, please try again'
  haml :error_page
end

error TreeOfKnowledge::ConnectionError do
  'Error connecting to Tree of Knowledge server, please try again'
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
  
  def search(query, scope)
  
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
       @results << {
        :id => @index[id]["id"], 
        :name => @index[id]["name"],
        :model => @index[id]["class"],
        :result => @index[id].load,
        :highlight => @index.highlight(query, id, :field => field, :num_excerpts => 2, :excerpt_length => 15, :pre_tag => "<em>", :post_tag => "</em>")
        } if scope == "all" or scope.singularize == @index[id]["class"].downcase
    end
    
    return @results
  end

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="ToK HTTP Auth")
      throw :halt, [401, "Not authorized\n"]
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [options.username, options.password]
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

get '/search' do
  @user_query = params[:query].chomp.downcase
  @results = search(@user_query, 'all')
  @title = @user_query + " : Search"
  display :search, :layouts => :'layouts/search'
end

get '/results' do
  @user_query = params[:query].chomp.downcase
  
  #activities
  #@activities = search(@user_query, 'activity')
  #courses
  @courses = search(@user_query, 'course')
  #resources
  @resources = search(@user_query, 'resource')
  #people
  @people = search(@user_query, 'person')
  #all
  @results = search(@user_query, 'all')
    
  @title = params[:query] + " : Search"
  haml :results, :locals => {:sidebar => :_search_options}
end

get '/tok-input' do
  protected!
  
  @knol = $yggdrasil.get_resource 'Knowledge'
  haml :tok_adding
end

post '/tok-input' do
  protected!
  
  $yggdrasil.add_resource '/Knowledge/' + params[:path]
  redirect '/tok-input', 303 # Reset to GET
end

get '/:class/:id' do
  @object = params[:class].capitalize.to_class.new params[:id]
  @title = (@object.name || @object._id).to_s + " : " + params[:class].capitalize.pluralize
  display params[:class].to_sym
end

get '/course' do
  @collection = Course.get_all
  @collection = @collection.sort_by { |x| [x.year,x.semester,x.name]}
  params[:class] = "courses"
  @title = params[:class].capitalize
  display :courses
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
