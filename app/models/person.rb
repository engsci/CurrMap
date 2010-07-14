class Person
  include Mongoid::Document
  
  field :name, :type => String
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String
  
  #references_many :courses, :stored_as => :array, :inverse_of => :people 
  
  def short_name
    self.id
  end
end