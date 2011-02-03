class Course
  include Mongoid::Document
  
  key :course_code
  
  field :course_code, :type => String
  
  attr_accessible :name
  
  field :name, :type => String
  
  references_and_referenced_in_many :collections, :index => true
  references_and_referenced_in_many :course_instances, :index => true
  
  # VALIDATIONS
  
  validates_presence_of :name, :course_code
  validates_format_of :course_code, :with => /[A-Za-z]{3}[0-9]{3}/, :message => "must be of form ABC123"
  
  # SEARCH
  
end
