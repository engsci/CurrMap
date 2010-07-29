class Person
  include Mongoid::Document
  identity :type => String
  
  field :name, :type => String
  
  def short_name
    self.id
  end
  
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

class Employee < Person
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String
end

class Professor < Employee
  references_many :courses, :stored_as => :array, :inverse_of => :professors, :index => true
end

class Author < Person

end
