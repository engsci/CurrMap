module CoursesHelper
  
  def course_path_(course, action = :show)
    {:controller => :courses, :action => action, :id => course.short_code, :delivered_year => course.delivered_year}
  end
  
end
