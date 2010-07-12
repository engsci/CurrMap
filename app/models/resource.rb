class Resource
  include Mongoid::Document
  
  field :isbn, :type => String
  field :author, :type => String #array
  field :edition, :type => Integer
  field :name, :type => String
  field :publisher, :type => String
  field :type, :type => String
  
  references_many :courses, :stored_as => :array, :inverse_of => :resources
end