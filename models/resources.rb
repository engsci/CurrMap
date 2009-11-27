require 'orm'

class Resource < CouchDoc
  field_getters %w(ISBN edition name author publisher type)
end
