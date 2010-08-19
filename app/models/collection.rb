class Collection
  include Mongoid::Document
  identity :type => String
  
  def name
    return id
  end
  
  def parents
    Collection.where(:collection_ids => self.id)
  end
  
  references_many :courses, :stored_as => :array, :inverse_of => :collections, :index => true
  references_many :collections, :stored_as => :array
  
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