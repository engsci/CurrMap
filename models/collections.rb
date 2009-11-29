class Collection < CouchDoc
 attr_reader :courses
 id_accessor :_id
 
 def initialize(_id)
   super _id
   add_nested_docs "courses", :default_field => "course_code"
 end
end
