require 'json'
require 'couch'

class CouchDoc
  
  def initialize(init)
    if init.kind_of? Hash
      @couch_data = init
    else
      @couch_data = get_by_id init
    end
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

    def id_accessor name
      define_method name do
        return @couch_data["_id"]
      end
    end
    
  end
  
end

class Course < CouchDoc
  attr_reader :staff
  field_getters %w(name activities weight calendar\ entry)
  id_accessor :course_code  
  
  def initialize(course_code)
    super course_code
    @staff = @couch_data["staff"].keys.map { |prof| Staff.new prof }
  end
  

end

class Staff < CouchDoc
  field_getters %w(email name phone website)
  id_accessor :short_name
end

class Resource < CouchDoc
  field_getters %w(ISBN edition name author publisher type)
end
