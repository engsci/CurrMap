class Collection
  include Mongoid::Document
  identity :type => String
  
  def parents
    Collection.where(:collection_ids => self.id)
  end
  
  references_and_referenced_in_many :courses,  :inverse_of => :collections, :index => true
  references_and_referenced_in_many :collections
  
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
