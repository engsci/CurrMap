class CoursesController < ApplicationController
  
  # before_filter :authenticate_user!, :except => [:show]
 
  # GET /courses
  # GET /courses.xml
  def index
	  #authorize! :manage, Course
  
    @courses_by_year_and_semester = {}
    
   Course.all.each do |course|
      @courses_by_year_and_semester[course.year_version] ||= {}
      @courses_by_year_and_semester[course.year_version][course.year] ||= {}
      @courses_by_year_and_semester[course.year_version][course.year][course.semester] ||= []
      @courses_by_year_and_semester[course.year_version][course.year][course.semester] << course
    end
    
    
    @courses_by_magic = {}
    # @courses_by_magic[course.year][course.semester][course] = [year_version, year_version]
    Course.all.each do |course|
      @courses_by_magic[course.year] ||= {}
      @courses_by_magic[course.year][course.semester] ||= {}
      @courses_by_magic[course.year][course.semester][course.short_code] ||= []
      @courses_by_magic[course.year][course.semester][course.short_code] << course.year_version
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  # GET /courses/1
  # GET /courses/1.xml
  def show
    Person #need this in development mode b/c person subclasses aren't being eagerloaded :@

    respond_to do |format|
      format.js {
        #just display the one course, using its docid
        @course = Course.where(:_id => params[:id])[0]
        @course ||= Course.where(:course_code => /^#{params[:id]}/)[0]
      }
      format.html {
        
        # redirect to most recent
        unless params[:year]
          redirect_to :year => Course.where(:course_code => /^#{params[:id]}/).desc(:year).limit(1)[0].year_version
        end
        
        #display the course, with tabs for related courses (same code, different year)
        @courses = Course.where(:course_code => /^#{params[:id]}/).sort_by{|course| course.year_version}.reverse
        @course = @courses[0]
        
        @profs_by_year = {}
        @resources_by_year = {}
        @courses.each do |course|
          course.professors.each do |prof|
            @profs_by_year[prof] ||= []
            @profs_by_year[prof] << course.year_version
          end
          course.resources.each do |resource|
            @resources_by_year[resource] ||= []
            @resources_by_year[resource] << course.year_version
          end
        end
        @profs_by_year = @profs_by_year.sort_by{ |p| p.last }.reverse
        
      }
      format.xml  { render :xml => @course }
    end
  end
  
  def overview
     @course = Course.find_course(params[:id], params[:year])      
  end

  def syllabus
    @course = Course.find_course(params[:id], params[:year])
  end
  
  def lectures
    @course = Course.find_course(params[:id], params[:year])
  end
  
  def resources
    @course = Course.find_course(params[:id], params[:year])
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
    @course = Course.find_course(params[:id], params[:year])
  end
  
  def calendar
    @course = Course.find_course(params[:id], params[:year])
  end


  # GET /courses/new
  # GET /courses/new.xml
  def new
    @course = Course.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find_course(params[:id], params[:year])
    
    respond_to do |format|
      format.js {
        #@course = Course.find(params[:id])
      }
      format.html {
        #@courses = Course.where(:course_code => /^#{params[:id]}/).sort_by{|course| course.year_version}.reverse
        #@course = @courses[0]
      }
    end
  end

  # POST /courses
  # POST /courses.xml
  def create
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        format.html { redirect_to(@course, :notice => 'Course was successfully created.') }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    @course = Course.find(params[:id])
    redirect_to(@course, :notice => 'Course was successfully pseudo-updated.')
    
    

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to(@course, :notice => 'Course was successfully updated.') }
        format.xml  { •••••••head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end if false
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
end
