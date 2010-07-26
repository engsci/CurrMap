class Course
  include Mongoid::Document
  identity :type => String
  
  # FIELDS
  #field :course_code, :type => String
  field :calendar_entry, :type => String
  field :name, :type => String
  field :semester, :type => String
  field :weight, :type => Float
  #workload for lecture, tutorial, practice
  
  # RELATIONSHIPS
  #embeds_many :activities
  references_many :resources, :stored_as => :array, :inverse_of => :courses, :index => true
  references_many :professors, :stored_as => :array, :inverse_of => :courses, :index => true
  references_many :collections, :stored_as => :array, :inverse_of => :courses, :index => true
  
  # VALIDATIONS
  #validates_presence_of :course_code, :name
  
  # OTHER
  
  #ID should be key
  #key :course_code
  
  #references_many :related_concepts, :stored_as => :array, :inverse_of => :courses 
  #references_many :courses, :stored_as => :array, :inverse_of => :related_courses
  
  # METHODS
  def course_code
    return self._id
  end
  def year
    return self.course_code[3,1]
  end
  
  def short_code
    return self.course_code[0,6]
  end
  
  # SEARCH
  include Sunspot::Mongoid
  searchable do
    text :name
    text :calendar_entry
    text :course_code
  end
end