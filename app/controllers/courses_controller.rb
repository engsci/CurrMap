class CoursesController < ApplicationController
  
  before_filter :authenticate_admin!, :except => [:index, :show]
  
  # GET /courses
  # GET /courses.xml
  def index
    @courses = Course.all.sort_by { |x| [x.year,x.semester,x.name]}

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
        @course = Course.find(params[:id])
      }
      format.html {
        #display the course, with tabs for related courses (same code, different year)
        @courses = Course.where(:course_code => /^#{params[:id]}/).sort_by{|course| course.year_version}.reverse
      }
      format.xml  { render :xml => @course }
    end
  end
  
  def lectures
    self.activities.find_all{|a| a.class == Lecture}
  end
  
  def midterms
    self.activities.find_all{|a| a.class == Midterm}
  end
  
  def year
    return self.course_code[3,1]
  end
  
  def short_code
    return self.course_code[0,6]
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
