require 'orm'

class Staff < CouchDoc
  field_getters %w(email name phone website)
  id_accessor :short_name
end
