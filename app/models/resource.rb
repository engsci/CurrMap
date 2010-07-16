class Resource
  include Mongoid::Document
  
  field :isbn, :type => String
  field :authors, :type => Array
  field :edition, :type => String #Integer
  field :name, :type => String
  field :publisher, :type => String
  field :optional, :type => Boolean
 # field :type, :type => String
  def name
    read_attribute(:name) || self.id
  end
  
  def author
    authors[0]
  end
  
  references_many :courses, :stored_as => :array, :inverse_of => :resources
  
  #def logger
  #  RAILS_DEFAULT_LOGGER
  #end
  
  def author
    read_attribute(:author) || "Unknown"
  end
  
  # SEARCH
  
  include Sunspot::Mongoid
  searchable do
    text :publisher
    text :name
    text :author
    text :isbn
  end  
  
  
end