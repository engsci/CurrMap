class Activity
  include Mongoid::Document
  identity :type => String
  
  field :week, :type => Integer
  #field :type, :type => String
  field :number, :type => String
  field :mode, :type => String
  
  embedded_in :course, :inverse_of => :activities
  
  embeds_many :concepts
end
