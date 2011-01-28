require 'net/http'
require 'uri'
require 'active_support'

class Term
  attr_reader :name, :id, :relns, :synonyms, :subtopics, :preferred
  attr_reader :errors

  def initialize(info)
    @id        = info['id'] || info[:id] || 0
    @name      = info['name'] || info[:name]
    @relns     = info['relns'] || info[:relns]
    @synonyms  = info['synonyms'] || info[:synonyms]
    @preferred = info['preferred'] || info[:preferred]
    if info['subtopics']
      @subtopics = info['subtopics'].map { |sub| Term.new(sub) }
    elsif info[:subtopics]
      @subtopics = info[:subtopics].map { |sub| Term.new(sub) }
    else
      @subtopics = nil
    end
    @errors = []
  end

  def to_key
    [@id]
  end

  def to_h
    hsh = {}
    %w(id name relns synonyms preferred).each do |prop|
      hsh[prop] = self.instance_variable_get(('@' + prop).intern)
    end
    hsh['subtopics'] = @subtopics.map(&:to_h)
    return hsh
  end

  def save
    if @name && !@name.blank?
      begin
        saved = Term.add_resource @name
      rescue Term::ConnectionError
        err_resp = $!.result.response
        @errors = ["Connection Error: #{err_resp.code}: #{err_resp.message}"]
        return false
      end
      return saved
    else
      @errors = ['Name cannot be blank']
      return false
    end
  end

  class << self


    def model_name
      TmpStr.new(self.to_s)
    end

    def root
      Term.new(get_resource 'Knowledge')
    end

    def lookup word
      if word.respond_to :map
        return word.map {|w| lookup w}
      else
        return Term.new(get_resource ['Knowledge', word].join '/')
      end
    end

    protected

    class TmpStr < String
      def singular
        self.downcase
      end
      def plural
        self.downcase + "s"
      end
    end

    def strip_path(path)
      path.gsub %r{ (^/) | (/$) }xms, ''
    end

    def get_uri(path)
      path = strip_path path
      path = [ENV['TOK_PATH'], path].join '/' unless ENV['TOK_PATH'].blank?
      URI.parse("http://#{ENV['TOK_HOST']}:#{ENV['TOK_PORT']}/#{path}")
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

    class ConnectionError < RuntimeError
      attr_reader :result, :request
      def initialize(request, result)
        @request = request
        @result = result
      end
    end
  end
end
