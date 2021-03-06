class PagesController < ApplicationController
  
  def index


 
  end
  
  def search
    @query = params[:query]
    
    search = Sunspot.search(CourseInstance, Textbook, Instructor, Collection) do |query|
      query.keywords(@query) do
        boost_fields :name => 2
        phrase_fields :name => 2
      end
      query.paginate(:page => 1, :per_page => 50)
    end
    @results = search.results
    @resources = @results.select {|i| i.class == Textbook }
    @people = @results.select {|i| i.class.ancestors.include? Person }
    @courses = @results.select {|i| i.class == CourseInstance } 
    @collections = @results.select {|i| i.class == Collection }
    @enable_all = false
    
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def unauthorized
  end
 
  def about
  end
  
  def help
  end
  
  def contact
  end
  
end
