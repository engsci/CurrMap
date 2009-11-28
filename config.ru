require 'currmap'
require 'partials'
class Sinatra::Application
  include Sinatra::Partials
end
run Sinatra::Application
