require 'orm'

class Activity < CouchDoc
  id_accessor :key
end

class Lecture < Activity
end

class Midterm < Activity
end
