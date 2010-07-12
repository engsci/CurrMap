class Course
  include Mongoid::Document
  
  # FIELDS
  field :course_code, :type => String
  field :calendar_entry, :type => String
  field :name, :type => String
  field :semester, :type => String
  field :weight, :type => Float
  #workload for lecture, tutorial, practice
  
  # RELATIONSHIPS
  embeds_many :activities
  references_many :resources, :stored_as => :array, :inverse_of => :courses
  references_many :people, :stored_as => :array, :inverse_of => :courses #should have role as well
  references_many :collections, :stored_as => :array, :inverse_of => :courses
  
  
  # VALIDATIONS
  validates_presence_of :course_code, :name
  
  # OTHER
  
  #ID should be key
  #key :course_code
  
  #references_many :related_concepts, :stored_as => :array, :inverse_of => :courses 
  #references_many :courses, :stored_as => :array, :inverse_of => :related_courses
  
end
