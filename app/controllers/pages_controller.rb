class PagesController < ApplicationController
  def index
  end
  
  def search
    @query = params[:query]
    
    search = Sunspot.search(Course, Resource, Person) do |query|
      query.keywords(@query) do
        boost_fields :name => 2
        phrase_fields :name => 2
      end
      query.paginate(:page => 1, :per_page => 50)
    end
    @results = search.results
    @resources = @results.select {|i| i.class == Resource }
    @people = @results.select {|i| i.class == Person }
    @courses = @results.select {|i| i.class == Course } 
    @enable_all = false
  end
  
end