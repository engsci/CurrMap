class Concept
  #references_many :courses, :stored_as => :array, :inverse_of => :related_concepts
  embedded_in :courses, :inverse_of => :concepts
end