require 'json'
require 'couch'

db = "currmap"
view = "testing"

views = {
  "_id" => "_design/#{view}",
  "views" => {
    "Courses" => {
      "map" => "function(doc) { if (doc[\"_id\"].match(/[A-Z]{3}[0-9]{3}/i) ) { emit(doc[\"_id\"], doc); } }"
    }
  }
}

def add_views
  server = Couch::Server.new('localhost', 5984)
  server.put("/#{db}/_design/#{view}", views.to_json)
end
