class Resource
  include Mongoid::Document
  identity :type => String
  
  field :isbn, :type => String
  field :authors, :type => Array
  field :edition, :type => String #Integer
  field :name, :type => String
  field :publisher, :type => String
  field :optional, :type => Boolean
 # field :type, :type => String
  
  def author
    authors[0]
  end
  
  references_many :courses, :stored_as => :array, :inverse_of => :resources, :index => true
  
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
    text :authors do 
      self.authors ? self.authors.join(" ") : nil
    end
    text :isbn
  end  
  
  
end