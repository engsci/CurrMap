require 'orm'

class Course < CouchDoc
  attr_reader :staff
  attr_reader :activities
  attr_reader :resources
  id_accessor :course_code  
  
  def initialize(course_code)
    super course_code
    @staff = @couch_data["staff"].keys.map { |prof| Staff.new prof }
    if @couch_data["resources"]
      @resources = @couch_data["resources"].map do |resource|
        begin 
          Resource.new resource
        rescue
          Resource.new "name" => resource
        end
      end
    else
      @resources = []
    end
    if @couch_data["activities"]
      @activities = @couch_data["activities"].map do |key,activity|
        if key =~ /^L\d+/
          Lecture.new activity
        elsif key =~ /^MT\d+/
          Midterm.new activity
        else
          Activity.new activity
        end
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
