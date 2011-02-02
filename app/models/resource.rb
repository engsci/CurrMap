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
 
  embeds_many :authors
  accepts_nested_attributes_for :authors
  
  validates_presence_of :name
  
  #def author
  #  authors[0]
  #end
  
  references_and_referenced_in_many :courses, :inverse_of => :resources, :index => true
  
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

class Author
  include Mongoid::Document
  
  field :name
  
  embedded_in :course
  
  def to_s
    self.name
  end
end
