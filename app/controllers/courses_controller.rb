class CoursesController < ApplicationController
  
  load_and_authorize_resource :only => [:index]
 
  # GET /courses
  # GET /courses.xml
  def index
	  #authorize! :manage, Course
    @courses = Course.all
    
    @courses_by_year_and_semester = {}
    #TODO: add field limit(...) to this query
    CourseInstance.all.each do |course|
      @courses_by_year_and_semester[course.delivered_year] ||= {}
      @courses_by_year_and_semester[course.delivered_year][course.level] ||= {}
      @courses_by_year_and_semester[course.delivered_year][course.level][course.semester] ||= []
      @courses_by_year_and_semester[course.delivered_year][course.level][course.semester] << course
    end

    @courses_by_magic = {}
    # @courses_by_magic[course.year][course.semester][course] = [delivered_year, delivered_year]
    CourseInstance.all.each do |course|
      @courses_by_magic[course.level] ||= {}
      @courses_by_magic[course.level][course.semester] ||= {}
      @courses_by_magic[course.level][course.semester][course.short_code] ||= []
      @courses_by_magic[course.level][course.semester][course.short_code] << course.delivered_year
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
      format.js { 
        render :json => Course.search_as_you_type(params[:term]) 
        }
    end
  end
  
  def show
    @course = Course.find(params[:id])     
    
    respond_to do |format|
      format.html {
        if @course.respond_to?('course_instances') && @course.course_instances.length > 0
          redirect_to course_instance_path(@course, @course.course_instances.sort_by {|c| c.delivered_year }.reverse[0])
        end
      }
    end
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
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save && @course.update_relations(params[:course])
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

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to(@course, :notice => 'Course was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
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
