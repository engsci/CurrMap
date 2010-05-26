require 'net/http'
require 'uri'

module TreeOfKnowledge
  class Client
    def initialize(host, port, username, password)
      @host = host
      @port = port
      @user = username
      @pass = password
    end

    def get_resource(path)
      uri = URI.parse("http://" + host + ":" + port + path)
      req = Net::HTTP::Get.new(uri.path)
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end
      Marshal.load(res.body)
    end

    def add_resource(path)
      uri = URI.parse("http://" + host + ":" + port + path)
      req = Net::HTTP::Put.new(uri.path)
      req.basic_auth @user, @pass
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end
      Marshal.load(res.body)
    end
  end
end
