require 'cgi'
require 'net/http'
require 'uri'
require 'active_support'

class ConnectionError < RuntimeError
  attr_reader :result, :request
  def initialize(request, result)
    @request = request
    @result = result
  end
end

class Term
  attr_reader :name, :relns, :id, :synonyms, :subtopics, :preferred,
    :supertopics, :path
  attr_reader :error_messages

  def initialize(info = {})
    from_hash info
    @error_messages = []
  end

  def from_hash(hash)
    @id          = hash['id']          || hash[:id]          || 0
    @name        = hash['name']        || hash[:name]
    @path        = hash['path']        || hash[:path]
    @relns       = hash['relns']       || hash[:relns]
    @synonyms    = hash['synonyms']    || hash[:synonyms]
    @preferred   = hash['preferred']   || hash[:preferred]
    @supertopics = hash['supertopics'] || hash[:supertopics]
    subtopics    = hash['subtopics']   || hash[:subtopics]
    @subtopics   = subtopics.map { |sub| Term.new(sub) } if subtopics
  end

  def to_key
    [@id.to_s]
  end

  def to_s
    @id.to_s
  end

  def to_h
    hsh = {}
    %w(id name relns synonyms preferred supertopics).each do |prop|
      hsh[prop] = self.instance_variable_get(('@' + prop).intern)
    end
    hsh['subtopics'] = @subtopics.map(&:to_h)
    return hsh
  end

  def persisted?
    @id != 0
  end

  def save
    if @name && !@name.blank?
      begin
        saved = Term.add_resource @name
      rescue ConnectionError
        err_resp = $!.result.response
        @error_messages = ["Connection Error: #{err_resp.code}: #{err_resp.message}"]
        return false
      end
      from_hash saved
      return saved
    else
      @error_messages = ['Name cannot be blank']
      return false
    end
  end

  def to_model
    self
  end

  class << self

    def model_name
      ActiveModel::Name.new(self)
    end

    def find identifier
      begin
        if identifier.is_a? Fixnum
          return Term.new(get_resource "id/#{identifier}")
        else
          return Term.new(get_resource "Knowledge/#{identifier}")
        end
      rescue ConnectionError
        return nil
      end
    end

    def search query
      get_resource "Search/#{query}", :fuzzy => true
    end

    def root
      Term.new(get_resource 'Knowledge')
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

    protected

    def strip_path(path)
      path.gsub %r{ (^/) | (/$) }xms, ''
    end

    def get_uri(path)
      path = path.split('/').map {|p| CGI.escape p}.join('/')
      path = strip_path path
      path = [ENV['TOK_PATH'], path].join '/' unless ENV['TOK_PATH'].blank?
      URI.parse("http://#{ENV['TOK_HOST']}:#{ENV['TOK_PORT']}/#{path}")
    end

    def get_resource(path, params=nil)
      uri = get_uri(path)
      path = uri.path
      if params
        path << "?" << params.map {|k,v| "#{k}=#{v}"}.join('&')
      end
      req = Net::HTTP::Get.new(path)
      res = request(req)
      Marshal.load(res.body)
    end

    def put_to(path, params=nil)
      uri = get_uri(path)
      path = uri.path
      if params
        path << "?" << params.map {|k,v| "#{k}=#{v}"}.join('&')
      end
      req = Net::HTTP::Put.new(path)
      req.basic_auth ENV['TOK_USER'], ENV['TOK_PASS']
      res = request(req)
      Marshal.load(res.body)
    end

    def request(req)
      begin
        res = Net::HTTP.start(ENV['TOK_HOST'], ENV['TOK_PORT']) do |http|
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
end
