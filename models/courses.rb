require 'orm'

class Course < CouchDoc
  attr_reader :staff
  attr_reader :activities
  attr_reader :resources
  id_accessor :course_code  
  
  def initialize(course_code)
    super course_code
    add_nested_docs "staff", :by_key => true
    add_nested_docs "resources"
    add_nested_docs "activities" do |key,activity|
      if key =~ /^L\d+/
        Lecture.new activity
      elsif key =~ /^MT\d+/
        Midterm.new activity
      else
        Activity.new activity
      end
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
  
end
