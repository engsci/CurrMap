require 'currmap'
require 'partials'
class Sinatra::Application
  include Sinatra::Partials
end
Sinatra::Application.set(
  :run => false,
  :environment => ENV['RACK_ENV']
)
run Sinatra::Application
