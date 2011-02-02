class Collection
  include Mongoid::Document
  
  field :name, :type => String
  
  references_and_referenced_in_many :courses,  :inverse_of => :collections, :index => true
  references_and_referenced_in_many :collections
  
  def parents
    Collection.where(:collection_ids => self.id)
  end
  
  
  
  #include Sunspot::Mongoid
  searchable do
    text :name do
      id
    end
    text :course_names do 
      self.courses.map(&:name).join(" ")
    end
  end if false
  
end
