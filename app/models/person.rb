class Person
  include Mongoid::Document
  identity :type => String
  
  field :name, :type => String
  
  # SEARCH
  
  include Sunspot::Mongoid
  searchable do
    text :name
    text :course_descriptions do
      self.courses.map(&:calendar_entry).join(" ")
    end
    text :course_names do 
      self.courses.map(&:name).join(" ")
    end
  end

end

#class Employee < Person
#  
#end

class Professor < Person
  references_and_referenced_in_many :courses, :inverse_of => :professors, :index => true
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String
  
  def years_taught
    self.courses.map{|x| x.delivered_year}.uniq.sort
  end
end

class Author < Person

end
