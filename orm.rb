require 'json'
require 'couch'

class CouchDoc
  
  def initialize(id)
    @couch_data = get_by_id id
  end
  
  def get_by_id(id)
    return JSON.parse(Couch::Server.new('localhost', 5984).get("/currmap/#{id}").body)
  end
  
  class << self

    def field_getters(names)
      names.each do |name|
        define_method name.gsub(/ /, '_') do
          return @couch_data[name]
        end
      end
    end
    
  end
  
end

class Course < CouchDoc
  attr_reader :staff
  field_getters %w(name activities weight calendar\ entry)
  
  def initialize(course_code)
    super course_code
    @staff = @couch_data["staff"].keys.map { |prof| Staff.new prof }
  end
  
end

class Staff < CouchDoc
  field_getters %w(email name phone website)
end

