#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'couch'

def add_views
  db = "currmap"
  view = "testing"
  
  view_names = ["Courses",
                "Staffs",
                "Resources",
                "Collections",
                "CoursesByProf",
                "All"
               ]

  view_defs = Hash.new
  view_names.each do |name|
    func = open(File.join("couch-views", name + ".js")).readlines.map(&:chomp).join('')
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

add_views
