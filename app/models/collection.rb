class Collection
  include Mongoid::Document
  
  attr_accessible :name
  
  field :name, :type => String
  
  # RELATIONAL
  
  references_and_referenced_in_many :collections, :index => true
  references_and_referenced_in_many :courses, :index => true
  references_and_referenced_in_many :course_instances, :index => true
  
  # VALIDATIONS
  
  validates_presence_of :name
  
  # METHODS 
  
  def parents
    Collection.where(:collection_ids => self.id)
  end
  
  # SEARCH
  
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
