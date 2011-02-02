





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
   
  authors = hash["author"].class == String ? hash["author"].to_a : hash["author"] 
  hash.delete("author")
  
  hash["medium"] = hash["type"]
  hash.delete("type")
  
  hash["name"] ||= hash["_id"]
  hash["old_id"] = hash["_id"]
  hash.delete("_id")
  
  resource = Resource.new(hash)
  
  authors.each do |a|
    resource.authors << Author.new(:name => a)
  end if authors && authors.length > 0
  
  resource.save
end

# NOTE: COURSES MUST BE IMPORTED AFTER PROFS

# IMPORT COURSES
puts "IMPORTING COURSES"
Person #initialize Prof, other subclasses
#Professor.sunspot_options = {} # sadface  
Course.destroy_all
CouchCourse.get_all.each do |c|
  hash = c.to_hash
  hash.delete("_rev")   
  hash.delete("class")     
  
  hash["calendar_description"] = hash["calendar_description"]
  hash.delete("calendar_description")
  
  hash["professor_ids"] = []
  profs = hash["staff"].keys if hash["staff"]
  hash.delete("staff")
  
  hash["resource_ids"] = []
  resources = hash["resources"]
  hash.delete("resources")
  
  main_topics = hash["main_topics"] || hash["main topics"]
  
  hash.delete("main topics")
  hash.delete("main_topics")
  
  puts hash["_id"] #LOG
  
  hash["course_code"] = hash["_id"].split("-")[0].strip #remove '- 2010' classification
  hash.delete("_id")
  
  hash["delivered_year"] = hash["year"].to_i
  hash.delete("year")
  
  
  course = Course.new(hash)
  
   # MAIN TOPICS
  
  main_topics.each do |t|
    topic = Topic.new(:name => t)
    course.main_topics << topic
  end if main_topics && main_topics.length > 0
  
 
  
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

if false

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