require 'app/extras/orm'

class CouchActivity < CouchDoc
  id_accessor :key
end

class CouchLecture < CouchActivity
end

class CouchMidterm < CouchActivity
end
