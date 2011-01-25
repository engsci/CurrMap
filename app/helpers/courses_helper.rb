module CoursesHelper
  
  def course_path_(course, action = :show)
    {:controller => :courses, :action => action, :id => course.short_code, :anchor => course.year_version}
  end
  
end
