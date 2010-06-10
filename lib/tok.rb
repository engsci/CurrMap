require 'net/http'
require 'uri'

module TreeOfKnowledge
  class Client
    def initialize(host, port, path, username, password)
      @host = host
      @port = port
      @path = strip_path path
      @user = username
      @pass = password
    end
    
    def strip_path(path)
      path.gsub %r{ (^/) | (/$) }xms, ''
    end
    
    def get_uri(path)
      path = strip_path path
      URI.parse("http://#{@host}:#{@port}/#{@path}/#{path}")
    end

    def get_resource(path)
      uri = get_uri(path)
      req = Net::HTTP::Get.new(uri.path)
      res = request(req)
      Marshal.load(res.body)
    end

    def add_resource(path)
      put_to path
    end
    
    def add_synonym(word1, word2, preferred=false)
      put_to "Synonym/#{word1}/#{word2}#{if preferred then '?preferred=true' else '' end}"
    end
    
    def add_relation(item1, reln, item2)
      put_to "Relation/#{item1}/#{reln}/#{item2}"
    end
    
    def put_to(path)
      uri = get_uri(path)
      full_path = uri.path
      if !uri.query.nil?
        full_path << "?" << uri.query
      end
      req = Net::HTTP::Put.new(full_path)
      req.basic_auth @user, @pass
      res = request(req)
      Marshal.load(res.body)
    end
    
    def request(req)
      begin
        res = Net::HTTP.start(@host, @port) do |http|
          http.request(req)
        end
      rescue Errno::ECONNREFUSED
        handle_error(req, res)
      end
      if not res.kind_of? Net::HTTPSuccess
        handle_error(req, res)
      end
      return res
    end
    
    def handle_error(req, res)
      e = ConnectionError.new(req, res)
      raise e
    end
    
  end
  
  class ConnectionError < RuntimeError
    attr_reader :result, :request
    def initialize(request, result)
      @request = request
      @result = result
    end
  end
    
end
