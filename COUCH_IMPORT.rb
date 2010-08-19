





# IMPORT PEOPLE
Person.destroy_all
CouchPerson.get_all.each do |p| 
  pp = p.to_hash
  pp.delete("_rev")
  pp.delete("class")
  q = Professor.new(pp)
  q.save
end

# IMPORT RESOURCES
Resource.destroy_all
CouchResource.get_all.each do |r|
  hash = r.to_hash
  hash.delete("_rev")
  hash.delete("class")
   
  hash["authors"] = hash["author"].class == String ? hash["author"].to_a : hash["author"] 
  hash.delete("author")
  
  hash["medium"] = hash["type"]
  hash.delete("type")
  
  resource = Resource.new(hash)
  resource.save
end

# NOTE: COURSES MUST BE IMPORTED AFTER PROFS

# IMPORT COURSES
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
  
  course = Course.new(hash)
  
  # LINK TO PROFS
  profs.each do |id|
    prof = Professor.find(id) 
    course.professors << prof
    prof.save
  end if profs
  
  # LINK TO RESOURCES
  resources.each do |id|
    resource = Resource.find(id)
    course.resources << resource
    resource.save
  end if resources
  
  course.save
end

Collection.destroy_all      
CouchCollection.get_all.each do |c|
  hash = c.to_hash
  hash.delete("_rev")   
  hash.delete("class")
  courses = hash["courses"]
  hash.delete("courses")
  hash.delete("collections") #linked seperately, see below
  
  
  collection = Collection.new(hash)
  
  courses.each do |id|
    course = Course.find(id)
    collection.courses << course
    course.save
  end if courses

  collection.save
end


#link collections to collections
CouchCollection.get_all.each do |c|
  hash = c.to_hash
  collections = hash["collections"]
  
  collection = Collection.find(hash["_id"])

  collections.each do |id|
    col = Collection.find(id)
    collection.collections << col
    #col.save
  end if collections
  
  collection.save
end

Person.remove_all_from_index
Resource.remove_all_from_index
Course.remove_all_from_index
Collection.remove_all_from_index

Sunspot.index(Person.all)
Sunspot.index(Resource.all)
Sunspot.index(Course.all)
Sunspot.index(Collection.all)