#!/usr/bin/env ruby
require 'json'
require 'couch'

def add_views
  db = "currmap"
  view = "testing"

  views = {
    "_id" => "_design/#{view}",
    "views" => {
      "Courses" => {
        "map" => "function(doc) { if (doc[\"class\"] == \"Course\" ) { emit(doc[\"_id\"], doc); } }"
      }
    }
  }

  server = Couch::Server.new('localhost', 5984)
  server.put("/#{db}/_design/#{view}", views.to_json)
end

add_views
