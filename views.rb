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
        "map" => "function(doc) { if (doc.class == 'Course' ) { emit(doc._id, doc); } }"
      },
      "Staffs" => {
        "map" => "function(doc) { if (doc.class == 'Staff' ) { emit(doc._id, doc); } }"
      },
      "Resources" => {
        "map" => "function(doc) { if (doc.class == 'Resource' ) { emit(doc._id, doc); } }"
      },
      "Collections" => {
        "map" => "function(doc) { if (doc.class == 'Collection' ) { emit(doc._id, doc); } }"
      },
      "CoursesByProf" => {
        "map" => "function(doc) { if (doc.class == 'Staff') { emit([doc._id, 0], doc); } else if (doc.class == 'Course') { for (var p in doc.staff) { emit([p,1], {'name': doc.name, '_id': doc._id}); } } }"
      },
      "All" => {
        "map" => "function(doc) { emit(doc._id, doc); }"
      }
    }
  }

  server = Couch::Server.new('localhost', 5984)
  views["_rev"] = JSON.parse(server.get("/#{db}/_design/#{view}").body)["_rev"]
  server.put("/#{db}/_design/#{view}", views.to_json)
end

add_views
