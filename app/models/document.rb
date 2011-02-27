class Document
  include Mongoid::Document
  
  field :file, :type => String
  mount_uploader :file, DocumentUploader
  
  #validates_presence_of :file
  
  references_and_referenced_in_many :course_instances
end