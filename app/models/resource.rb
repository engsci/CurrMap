class Resource
  include Mongoid::Document
  
  field :isbn, :type => String
  field :author, :type => Array
  field :edition, :type => Integer
  #field :name, :type => String
  field :publisher, :type => String
 # field :type, :type => String
  def name
    self.id
  end
  references_many :courses, :stored_as => :array, :inverse_of => :resources
end