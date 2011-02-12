class CourseInstancesController < ApplicationController
  
  # index is not nested, ie. it is /course_instances, not /course/.../instances (as with all the other)
  def index
    @course_instances = CourseInstance.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @course_instances }
      format.js { 
        render :json => CourseInstance.search_as_you_type(params[:term]) 
        }
    end
  end
  
  def show
    @course = CourseInstance.find(params[:id])
  end
  
  def overview
     @course = CourseInstance.find(params[:id])  
  end

  def syllabus
    @course = CourseInstance.find(params[:id])
  end
  
  def lectures
    @course = CourseInstance.find(params[:id])
  end
  
  def resources
    @course = CourseInstance.find(params[:id])
    
    @resource = Resource.skip(rand(20))[0]  
    require 'net/http'
    require 'json'
    require 'uri'

    #Ocwsearch.com API integration

    #Mandatory "About Us" url parameter
    our_url = "http%3a%2f%2fcurrmap.heroku.com"

    ocw_search = URI.escape(@course.name)
    ocw_url = "http://www.ocwsearch.com/api/v1/search.json?q=" + ocw_search + "&contact=" + our_url

    result = Net::HTTP.get(URI.parse(ocw_url))
    ocw = JSON.parse(result)

    @related_courses = ocw["Results"]  
  end
  
  def evaluations
    @course = CourseInstance.find(params[:id])
  end
  
  def calendar
    @course = CourseInstance.find(params[:id])
  end
  
  def new
    @course_instance = CourseInstance.new
    @course_instance.contact_hours = ContactHours.new
  end
  
  def create
    @course_instance = CourseInstance.find(params[:id])
  end
  
  def edit
    @course = CourseInstance.find(params[:id])
  end
  
  def update
    @course = CourseInstance.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course_instance])
        format.html { redirect_to(@course, :notice => 'Course instance was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @course_instance = CourseInstance.find(params[:id])
  end
  
  def add_connection
    @course_instance = CourseInstance.find(params[:id])
    
  end
  
  def remove_connection
    @course_instance = CourseInstance.find(params[:id])
  end
end