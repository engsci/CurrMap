class Course
  include Mongoid::Document
  
  field :course_code, :type => String
  field :calendar_entry, :type => String
  field :name, :type => String
  field :semester, :type => String
  field :weight, :type => Float
  
  key :course_code
  
  #references_many :staff
  #references_many :resources
end
