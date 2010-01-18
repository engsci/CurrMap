require 'orm'

class Staff < CouchDoc
  id_accessor :short_name
  attr_reader :courses_taught

  def initialize sname
    if sname.kind_of? Hash
      @couch_data = sname
    else
      # Using the CoursesByProf view to get both the professor and the courses they teach
      uri = File.join("/", @@db, "_design" , @@design_doc, "_view",
                      "CoursesByProf?startkey=[\"#{sname}\"]&endkey=[\"#{sname}\",2]")
      couch_got = JSON.parse(Couch::Server.new(@@couch_uri, @@couch_port).get(uri).body)["rows"]
      @couch_data = couch_got[0]["value"]
      courses = couch_got[1..-1]
      if not courses.nil?
        @courses_taught = courses.map { |c| c["value"] }
      end
    end
  end
end
