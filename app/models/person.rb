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
  references_many :courses, :stored_as => :array, :inverse_of => :professors, :index => true
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String
end

class Author < Person

end
