class Person
  include Mongoid::Document
  
  field :name, :type => String
  field :phone, :type => String
  field :website, :type => String
  
  references_many :courses, :stored_as => :array, :inverse_of => :people 
end