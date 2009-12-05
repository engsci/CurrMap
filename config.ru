require 'currmap'
require 'partials'
class Sinatra::Application
  include Sinatra::Partials
end
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => ENV['RACK_ENV']
)
run Sinatra::Application
