class Person
  include Mongoid::Document
  
  field :name, :type => String
  
  
  def to_s
    self.name
  end
  
  # SEARCH
  
  # include Sunspot::Mongoid
  searchable do
    text :name
    text :course_descriptions do
      self.courses.map(&:calendar_description).join(" ")
    end
    text :course_names do 
      self.courses.map(&:name).join(" ")
    end
  end if false

end

#class Employee < Person
#  
#end

class Professor < Person
  include Mongoid::Document
  
  references_and_referenced_in_many :courses, :inverse_of => :professors, :index => true
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String
  
  def years_taught
    self.courses.map{|x| x.delivered_year}.uniq.sort
  end
end
