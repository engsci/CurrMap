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
  
  def topics
     @course = CourseInstance.find(params[:id])
  end

  def activities
     @course = CourseInstance.find(params[:id])
  end
  
  def resources
    @course = CourseInstance.find(params[:id])
    
    require 'net/http'
    require 'json'
    require 'uri'

    #Ocwsearch.com API integration

    #Mandatory "About Us" url parameter
    our_url = "http%3a%2f%2fcurrmap.heroku.com"

    #Take only the first three words of the course title for the search terms
    ocw_search = URI.escape(@course.name.split(' ')[0..2].join(" "))
    @ocw_url = "http://www.ocwsearch.com/api/v1/search.json?q=" + ocw_search + "&contact=" + our_url

    result = Net::HTTP.get(URI.parse(@ocw_url))
    ocw = JSON.parse(result)
    @related_courses = ocw["Results"]

  end
  
  def editpreview
    @course = CourseInstance.find(params[:id])
  end
  
  #### CRUD follows
  
  def new
    @course = CourseInstance.new
    @course.contact_hours = ContactHours.new
    @course.course = Course.find(params[:course_id])
    @course.course_code = @course.course.course_code
  end
  
  def create
    @course = CourseInstance.new(params[:course_instance])
    @course.course_code = params[:course_instance][:course_code]
    @course.delivered_year = params[:course_instance][:delivered_year]
    @course.course = Course.find(params[:course_id])
    
    respond_to do |format|
      if @course.save && @course.update_relations(params[:course_instance])
        format.html { redirect_to(@course.course, :notice => 'Course Instance was successfully created.') }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
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
    @course = @course_instance.course
    @course_instance.destroy
    
    respond_to do |format|
      format.html { redirect_to(@course) }
      format.xml  { head :ok }
    end
  end
end
