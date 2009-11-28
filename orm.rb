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
    JSON.parse(Couch::Server.new('localhost', 5984).get("/currmap/#{id}").body)
  end
  
  def method_missing(meth, *args)
    @couch_data[meth.to_s]
  end
  
  def to_hash
    return @couch_data
  end
  
  class << self
    
    def get_all
      name = self.to_s
      JSON.parse(Couch::Server.new('localhost', 5984).
                 get("/currmap/_design/testing/_view/#{name}s").body
                 )["rows"].map do |doc|
        self.new doc["value"]
      end
    end

    def id_accessor name
      define_method name do
        return @couch_data["_id"]
      end
    end
    
  end
  
end

