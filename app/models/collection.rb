class Collection
  include Mongoid::Document
  
  field :type, :type => String
  
  references_many :courses, :stored_as => :array, :inverse_of => :collections
  
end