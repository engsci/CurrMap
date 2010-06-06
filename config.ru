require 'currmap'
Sinatra::Application.set(
  :run => false,
  :environment => ENV['RACK_ENV']
)
run Sinatra::Application
