class Person
  include Mongoid::Document
  
  field :name, :type => String
  
  def short_name
    self.id
  end
  
  # SEARCH
  
  include Sunspot::Mongoid
  searchable do
    text :name
  end

end

class Employee < Person
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String
end

class Professor < Employee
  references_many :courses, :stored_as => :array, :inverse_of => :professors
end

class Author < Person

end
