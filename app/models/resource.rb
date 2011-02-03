class Resource
  include Mongoid::Document

  attr_accessible :name, :optional
  
  field :name, :type => String
  field :optional, :type => Boolean
  
  validates_presence_of :name
  
  references_and_referenced_in_many :course_instances, :index => true
  
  # SEARCH
  
  if false
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
  
end

# TYPES

class Textbook < Resource  
  attr_accessible :isbn, :edition, :publisher, :authors_attributes
  
  field :isbn, :type => String
  field :edition, :type => String
  field :publisher, :type => String
  
  embeds_many :authors
  accepts_nested_attributes_for :authors, :reject_if => proc { |attributes| attributes['name'].blank? }
end

# EMBEDDED

class Author
  include Mongoid::Document
  
  attr_accessible :name
  
  field :name, :type => String
  
  validates_presence_of :name
  
  embedded_in :textbook
  
  def to_s
    self.name
  end
end
