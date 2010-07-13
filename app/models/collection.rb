class Collection
  include Mongoid::Document
  
  def name
    return id
  end
  #field :type, :type => String
  
 # references_many :courses, :stored_as => :array, :inverse_of => :collections
  
end