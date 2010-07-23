require 'orm'

class CouchCourse < CouchDoc
  if false
  attr_reader :people
  attr_reader :activities
  attr_reader :resources
  id_accessor :course_code  
  
  def initialize(course_code)
    super course_code
    add_nested_docs "people", :by_key => true
    # All this stuff is to deal with resources that are marked as optional
    # i.e. resources: { "name": "optional" }
    add_nested_docs "resources" do |resource|
      if resource.kind_of?(Array) and resource.second == "optional"
        r = CouchResource.new(resource.first)
        r.add_prop("optional", true)
        r
      else
        begin
          Resource.new resource
        rescue
          Resource.new "name" => resource
        end  
      end
    end
    add_nested_docs "activities" do |key,activity|
      if key =~ /^L\d+/
        CouchLecture.new activity
      elsif key =~ /^MT\d+/
        CouchMidterm.new activity
      else
        CouchActivity.new activity
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
  
end
