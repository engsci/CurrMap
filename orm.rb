require 'json'
require 'couch'

module CurrMap
  
  class << self
    attr_reader :server
    @@server = Couch::Server.new('localhost', 5984)
    def get_by_id(id)
      return JSON.parse(@@server.get("/currmap/#{id}").body)
    end
  end
  
  class Course

    attr_reader :staff
    
    def initialize(course_code)
      @course = CurrMap.get_by_id course_code
      @staff = @course["staff"].keys.map { |prof| CurrMap.get_by_id prof }
    end
    
    %w(name activities calendar\ entry weight class).each do |field|
      define_method field do
        return @course[field]
      end
    end
    
  end
  
end
