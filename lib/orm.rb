require 'rubygems'
require 'json'
require 'couch'

#require 'error_handling'
require 'active_support' # For singularize

class CouchDoc
  @@db = "currmap"
  @@design_doc = "testing"
  @@couch_uri = "localhost"
  @@couch_port = 5984
  
  def initialize(init)
    if init.kind_of? Hash
      @couch_data = init
    else
      begin
        @couch_data = get_by_id init
      rescue
        raise CouchConnectFailure
      end
    end
  end

  def get_by_id(id)
    JSON.parse(Couch::Server.new(@@couch_uri, @@couch_port).get("/#{@@db}/#{id.gsub(/ /, '%20')}").body)
  end
  
  def method_missing(meth, *args)
    @couch_data[meth.to_s]
  end
  
  def to_hash
    return @couch_data
  end
  
  def add_prop key, value
    @couch_data[key] = value
  end
  
  def add_nested_docs name, opt_hsh={}
    opt_hsh[:default_field] ||= "name"
    var_name = "@#{name}".intern
    class_name = name.singularize.capitalize
    doc_class = Object.const_get(class_name)
    mapping_block = Proc.new do |doc|
        if block_given?
          yield doc
        else
          begin 
            doc_class.new doc
          rescue
            doc_class.new opt_hsh[:default_field] => doc
          end
        end
      end
    
    if @couch_data[name]
      if opt_hsh[:by_key]
        to_set = @couch_data[name].keys.map { |doc| mapping_block.call doc }
      elsif opt_hsh[:by_value]
        to_set = @couch_data[name].values.map { |doc| mapping_block.call doc }
      elsif @couch_data[name].kind_of?(Hash) or @couch_data[name].kind_of?(Array)
        to_set = @couch_data[name].map { |doc| mapping_block.call doc }
      elsif @couch_data[name].kind_of? String
        to_set = [mapping_block.call(@couch_data[name])]
      end
    else
      to_set = []
    end
    self.instance_variable_set(var_name, to_set)
  end
  
  def type
    return @couch_data["type"]
  end
  
  class << self
    def get_view(view)
      return File.join("/", @@db, "_design", @@design_doc, "_view", view.pluralize)
    end
    
    def get_all
      begin
        name = self.to_s
        JSON.parse(Couch::Server.new(@@couch_uri, @@couch_port).
                   get(get_view(name)).body
                   )["rows"].map do |doc|
          self.new doc["value"]
        end
      rescue
        #raise CouchConnectFailure
      end
    end

    def id_accessor name
      define_method name do
        return @couch_data["_id"]
      end
    end
  end
  
end

