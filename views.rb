#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require File.join(File.dirname(__FILE__), 'couch')

def add_views
  db = "currmap"
  view = "testing"
  
  view_dir = "couch-views"
  
  view_defs = Hash.new
  Dir["./#{view_dir}/*.js"].each do |file|
    name = file.match /([^\/])+(?=.js$)/
    func = open(file).readlines.map(&:chomp).join('')
    view_defs[name] = { "map" => func }
  end
  
  views = {
    "_id" => "_design/#{view}",
    "views" => view_defs
  }

  server = Couch::Server.new('localhost', 5984)
  views["_rev"] = JSON.parse(server.get("/#{db}/_design/#{view}").body)["_rev"]
  server.put("/#{db}/_design/#{view}", views.to_json)
end

if __FILE__ == $0
  puts "Updating views..."
  add_views
  puts "Done."
end
