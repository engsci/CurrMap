require 'app/extras/orm'

class CouchPerson < CouchDoc
  if false
    id_accessor :short_name
    attr_reader :courses_taught

    def initialize sname
      if sname.kind_of? Hash
        @couch_data = sname
      else
        # Using the CoursesByProf view to get both the instructor and the courses they teach
        uri = File.join("/", @@db, "_design" , @@design_doc, "_view",
                        "CoursesByProf?startkey=[\"#{sname}\"]&endkey=[\"#{sname}\",2]")
        couch_got = JSON.parse(Couch::Server.new(@@couch_uri, @@couch_port).get(uri).body)["rows"]
        if couch_got[0]["value"]["class"] == "Person"
          @couch_data = couch_got[0]["value"]
          courses = couch_got[1..-1]
          if not courses.nil?
            @courses_taught = courses.map { |c| c["value"] }
          end
        else
          raise "No such person id #{sname}"
        end
      end
    end
  end
end