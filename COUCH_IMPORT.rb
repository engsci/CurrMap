# IMPORT PEOPLE

puts "IMPORTING PEOPLE"
Person.destroy_all
CouchPerson.get_all.each do |p| 
  hash = p.to_hash
  
  q = Instructor.new(hash)
  #name = q.name.sub(/[.]/,"").split(" ", 2)
  q.slug = hash["_id"]#|| name[0][0].chr.downcase + name[1].sub(/ /,"").underscore
  puts q.slug
  q.save
  
  puts q.errors if q.errors.length > 0
end



# IMPORT RESOURCES

puts "IMPORTING RESOURCES"
Resource.destroy_all
CouchResource.get_all.each do |r|
  hash = r.to_hash
   
  authors = hash["author"].class == String ? hash["author"].to_a : hash["author"] 
  
  hash["name"] ||= hash["_id"]
  hash["isbn"] = hash["ISBN"]
  
  puts hash["name"].to_s + " (" + hash["type"].to_s + ")"
  
  #hash["old_id"] = hash["_id"]
  if hash["ISBN"]
    resource = Textbook.new(hash)
  
    authors.each do |a|
      resource.authors << Author.new(:name => a)
    end if authors && authors.length > 0
  
    resource.save
  end
end

# NOTE: COURSES MUST BE IMPORTED AFTER PROFS

# IMPORT COURSES AND COURSE INSTANCES

puts "IMPORTING COURSES" 
Course.destroy_all
CourseInstance.destroy_all
CouchCourse.get_all.each do |c|
  hash = c.to_hash
  
  hash["calendar_description"] = hash["calendar_entry"]
  hash.delete("calendar_entry")
  
  profs = hash["staff"].keys if hash["staff"]
  resources = hash["resources"]
  main_topics = hash["main_topics"] || hash["main topics"]
  
  puts hash["_id"] #LOG
  
  hash["course_code"] = hash["_id"].split("-")[0].strip #remove '- 2010' classification
  
  hash["delivered_year"] = hash["year"].to_i
  
  # CREATE OR FIND RELATED COURSE
  unless course = Course.where(:_id => hash["course_code"][0,6].downcase).limit(1)[0]
    course = Course.new
    course.name = hash["name"]
    course.course_code = hash["course_code"][0,6]
    course.save
    puts course.errors if course.errors.length > 0
    
    puts course.course_code
  end
  
  course_inst = CourseInstance.new(hash)
  
  # PROTECTED ATTRIBUTES
  
  course_inst.delivered_year = hash["delivered_year"]
  course_inst.course_code = hash["course_code"]
  
  # CONTACT HOURS
  
  course_inst.contact_hours = ContactHours.new(hash["workload"])
  
  # MAIN TOPICS
  
  main_topics.each do |t|
    topic = Topic.new(:name => t)
    course_inst.main_topics << topic
  end if main_topics && main_topics.length > 0
  
  # ACTIVITIES
  
  activities = hash["activities"]
  
  activities.each do |src_activity|
    
    activity = src_activity[1]["type"].titleize.sub(/ /,'').classify.constantize.new(src_activity[1])
    
    src_activity[1]["outcomes"].each do |outcome|
      if outcome[0].length > 0
        topic = Topic.new(:name => outcome[0])
        activity.topics << topic
      end
    end
    
    course_inst.activities << activity
  end if activities && activities.length > 0
  
  course_inst.save
  puts course_inst.errors.inspect if course_inst.errors.length > 0
  
  break if course_inst.errors.length > 0
  
  # LINK TO COURSE
  
  course.course_instances << course_inst
  
  # LINK TO PROFS
  
  profs.each do |id|
    prof = Instructor.find(id)
    course_inst.instructors << prof
  end if profs
  
  
  # LINK TO RESOURCES

  resources.each do |id|
    if resource = Resource.where(:isbn => id)[0]
      course_inst.resources << resource
    end
  end if resources

end

# IMPORT COLLECTIONS

puts "IMPORTING COLLECTIONS"
Collection.destroy_all      
CouchCollection.get_all.each do |c|
  hash = c.to_hash

  courses = hash["courses"]
  
  hash["name"] = hash["_id"]
  
  collection = Collection.new(hash)
  
  collection.save
  
  courses.each do |id|
    course = Course.where(:course_code => /^#{id[0,6]}/)[0]
    collection.courses << course
  end if courses
  
end

# LINK COLLECTIONS to COLLECTIONS

puts "LINKING COLLECTIONS"

CouchCollection.get_all.each do |c|
  hash = c.to_hash
  collections = hash["collections"]
  
  collection = Collection.where(:name => hash["_id"])[0]

  collections.each do |id|
    col = Collection.where(:name => id)[0]
    collection.child_collections << col
  end if collections
  
end

# INDEX

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