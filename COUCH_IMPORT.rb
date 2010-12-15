





# IMPORT PEOPLE
puts "IMPORTING PEOPLE"
Person.destroy_all
CouchPerson.get_all.each do |p| 
  hash = p.to_hash
  hash.delete("_rev")
  hash.delete("class")
  hash["short_name"] = hash["_id"]
  hash.delete("_id")
  
  q = Professor.new(hash)
  q.save
end

# IMPORT RESOURCES
puts "IMPORTING RESOURCES"
Resource.destroy_all
CouchResource.get_all.each do |r|
  hash = r.to_hash
  hash.delete("_rev")
  hash.delete("class")
   
  hash["authors"] = hash["author"].class == String ? hash["author"].to_a : hash["author"] 
  hash.delete("author")
  
  hash["medium"] = hash["type"]
  hash.delete("type")
  
  hash["name"] ||= hash["_id"]
  hash["old_id"] = hash["_id"]
  hash.delete("_id")
  
  resource = Resource.new(hash)
  resource.save
end

# NOTE: COURSES MUST BE IMPORTED AFTER PROFS

# IMPORT COURSES
puts "IMPORTING COURSES"
Person #initialize Prof, other subclasses
Course.destroy_all
CouchCourse.get_all.each do |c|
  hash = c.to_hash
  hash.delete("_rev")   
  hash.delete("class")     
  
  hash["professor_ids"] = []
  profs = hash["staff"].keys if hash["staff"]
  hash.delete("staff")
  
  hash["resource_ids"] = []
  resources = hash["resources"]
  hash.delete("resources")
  
  if hash["main topics"]
    hash["main_topics"] = hash["main topics"]
    hash.delete("main topics")
  end
  
  puts hash["_id"] #LOG
  
  hash["course_code"] = hash["_id"].split("-")[0].strip #remove '- 2010' classification
  hash.delete("_id")
  
  course = Course.new(hash)
  
  # LINK TO PROFS
  profs.each do |id|
    prof = Professor.where(:short_name => id)[0]
    course.professors << prof
    prof.save
  end if profs
  
  # LINK TO RESOURCES
  resources.each do |id|
    resource = Resource.where(:old_id => id)[0]
    course.resources << resource
    resource.save
  end if resources
  
  course.save
end

puts "IMPORTING COLLECTIONS"
Collection.destroy_all      
CouchCollection.get_all.each do |c|
  hash = c.to_hash
  hash.delete("_rev")   
  hash.delete("class")
  courses = hash["courses"]
  hash.delete("courses")
  hash.delete("collections") #linked seperately, see below
  hash["name"] = hash["_id"]
  hash.delete("_id")
  
  collection = Collection.new(hash)
  
  courses.each do |id|
    course_versions = Course.where(:course_code => /^#{id}/)
    course_versions.each do |cv|
      collection.courses << cv
      cv.save
    end
  end if courses

  collection.save
end


puts "LINKING COLLECTIONS"
#link collections to collections
CouchCollection.get_all.each do |c|
  hash = c.to_hash
  collections = hash["collections"]
  
  collection = Collection.where(:name => hash["_id"])[0]

  collections.each do |id|
    col = Collection.where(:name => id)
    collection.collections << col
    #col.save
  end if collections
  
  collection.save
end

if true

  puts "CLEARING SOLR INDEX"
  Person.remove_all_from_index
  Resource.remove_all_from_index
  Course.remove_all_from_index
  Collection.remove_all_from_index

  puts "CREATING SOLR INDEX"
  Sunspot.index(Person.all)
  Sunspot.index(Resource.all)
  Sunspot.index(Course.all)
  Sunspot.index(Collection.all)

  puts "COMMITTING SOLR INDEX"
  Sunspot.commit
end