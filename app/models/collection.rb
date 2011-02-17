class Collection
  include Mongoid::Document
  include SexyRelations
  include Sunspot::Mongoid
  
  attr_accessible :name
  
  field :name, :type => String
  
  # RELATIONAL
  
  references_and_referenced_in_many :parent_collections, :inverse_of => :child_collections, :class_name => 'Collection'
  references_and_referenced_in_many :child_collections, :inverse_of => :parent_collections,  :class_name => 'Collection'
  
  references_and_referenced_in_many :courses, :index => true
  references_and_referenced_in_many :course_instances, :index => true
  
  # VALIDATIONS
  
  validates_presence_of :name
  
  # METHODS 
  
  def to_s
    name
  end
  
  # SEARCH
  
  def self.search_as_you_type(term)
    if term && term.length
      results = term.length > 1 ? Collection.where(:name => /#{term}/i) : Collection.where(:name => /^#{term}/i)
      return results.map {|x| {"label" => x.name, "id" => x._id, "value"=> x.name}}
    else
      return []
    end
  end
  
  searchable do
    text :name
    text :course_names do 
      self.courses.join(" ") + self.course_instances.map(&:name).join(" ")
    end
  end
  
end