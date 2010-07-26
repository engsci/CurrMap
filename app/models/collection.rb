class Collection
  include Mongoid::Document
  identity :type => String
  
  def name
    return id
  end
  
  def parents
    Collection.where(:collection_ids => self.id)
  end
  #field :type, :type => String
  
  references_many :courses, :stored_as => :array, :inverse_of => :collections, :index => true
  references_many :collections, :stored_as => :array
  
end