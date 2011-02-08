class CourseInstancesController < ApplicationController
  #def index
  #
  #end
  
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
      if @course.update_attributes(params[:course_instance]) && @course.update_instructors(params[:course_instance][:instructor])
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