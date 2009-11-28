#!/usr/bin/env ruby
require 'rubygems'
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
      },
      "Staff" => {
        "map" => "function(doc) { if (doc[\"class\"] == \"Staff\" ) { emit(doc[\"_id\"], doc); } }"
      },
      "Resources" => {
        "map" => "function(doc) { if (doc[\"class\"] == \"Resource\" ) { emit(doc[\"_id\"], doc); } }"
      }
    }
  }

  server = Couch::Server.new('localhost', 5984)
  views["_rev"] = JSON.parse(server.get("/#{db}/_design/#{view}").body)["_rev"]
  server.put("/#{db}/_design/#{view}", views.to_json)
end

add_views
