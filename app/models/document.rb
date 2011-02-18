class Document
  include Mongoid::Document
  
  field :document, :type => String
  mount_uploader :document, DocumentUploader
end