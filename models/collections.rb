class Collection < CouchDoc
 attr_reader :courses
 id_accessor :_id
 
 def initialize(_id)
    super _id
    if @couch_data["courses"]
      @courses = @couch_data["courses"].map do |course|
        begin 
          Course.new course
        rescue
          Course.new "course_code" => course
        end
      end
    else
      @courses = []
    end
  end
end
