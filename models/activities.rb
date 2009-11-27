require 'orm'

class Activity < CouchDoc
  field_getters %w(type mode number outcomes)
  id_accessor :key
end

class Lecture < Activity
  field_getters %w(week)
end

class Midterm < Activity
end
