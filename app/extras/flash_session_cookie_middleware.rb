require 'rack/utils'
 
class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      req = Rack::Request.new(env)
      ActionController::Base.logger = Logger.new(STDOUT)
      ActionController::Base.logger.debug "session_key: #{@session_key}"
      ActionController::Base.logger.debug  "param: #{req.params[@session_key]}"
      env['HTTP_COOKIE'] = [@session_key, req.params[@session_key]].join('=').freeze unless req.params[@session_key].nil?
      env['HTTP_ACCEPT'] = "#{req.params['_http_accept']}".freeze unless req.params['_http_accept'].nil?
    end

    @app.call(env)
  end
end