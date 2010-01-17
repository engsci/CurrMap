require 'orm'

class Staff < CouchDoc
  id_accessor :short_name
  attr_reader :courses_taught

  def initialize sname
    super sname
    uri = File.join("/", @@db, "_design" , @@design_doc, "_view",
                    "CoursesByProf?startkey=[\"#{self.short_name}\"]&endkey=[\"#{self.short_name}\",2]")
    courses = JSON.parse(Couch::Server.new(@@couch_uri, @@couch_port).get(uri).body)["rows"][1..-1]
    if not courses.nil?
      @courses_taught = courses.map { |c| c["value"] }
    end
  end
end
