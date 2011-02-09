class Collection
  include Mongoid::Document
  
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
  
  
  # SEARCH
  
  def self.search_as_you_type(term)
    if term && term.length
      results = term.length > 1 ? Collection.where(:name => /#{term}/i) : Collection.where(:name => /^#{term}/i)
      return results.map {|x| {"label" => x.name, "id" => x._id, "value"=> x.name}}
    else
      return []
    end
  end
  
  if false
    include Sunspot::Mongoid
    searchable do
      text :name do
        id
      end
      text :course_names do 
        self.courses.map(&:name).join(" ")
      end
    end
  end
  
end