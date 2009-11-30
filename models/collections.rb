require 'orm'

class Collection < CouchDoc
  attr_reader :courses
  attr_reader :collections
  id_accessor :_id

  def initialize(_id)
    super _id
    add_nested_docs "courses", :default_field => "course_code"
    add_nested_docs "collections"
  end
end
