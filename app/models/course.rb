class Course
  include Mongoid::Document
  identity :type => String
  
  # FIELDS
  field :course_code, :type => String
  field :calendar_entry, :type => String
  field :name, :type => String
  field :semester, :type => String
  field :weight, :type => Float
  field :year, :type => Integer
  #workload for lecture, tutorial, practice
  
  # RELATIONSHIPS
  # embeds_many :activities
  references_many :resources, :stored_as => :array, :inverse_of => :courses, :index => true
  references_many :professors, :stored_as => :array, :inverse_of => :courses, :index => true
  references_many :collections, :stored_as => :array, :inverse_of => :courses, :index => true
  
  # VALIDATIONS
  #validates_presence_of :course_code, :name
  
  # OTHER
  
  #ID should be key
  #key :course_code
  
  #references_many :related_concepts, :stored_as => :array, :inverse_of => :courses 
  #references_many :courses, :stored_as => :array, :inverse_of => :related_courses
  def init
    add_nested_docs "activities" do |key,activity|
      if key =~ /^L\d+/
        CouchLecture.new activity
      elsif key =~ /^MT\d+/
        CouchMidterm.new activity
      else
        CouchActivity.new activity
      end
    end
  end
  
  # METHODS  
  def name
    return read_attribute(:name).split(" - ")[0]
  end

  def year
    return self.course_code[3,1]
  end
  
  def year_version
    return read_attribute(:year)
  end
  
  def lectures
    return self.activities.find_all{|a| a.class}
  end
    
  def midterms
    return self.activities.find_all{|a| a.class}
  end  
  
  def short_code
    return self.course_code[0,6]
  end
  
  def collated_activities
    collated_activities = {}
    self.activities.each do |a|
      collated_activities[a[1]["week"]] ||= {"lectures" => [], "other" => []}
      if a[0] =~ /^L\d+/
        collated_activities[a[1]["week"]]["lectures"] << a
      else
        collated_activities[a[1]["week"]]["other"] << a
      end
    end
    return collated_activities
  end

  # SEARCH
  include Sunspot::Mongoid
  searchable do
    text :name
    text :calendar_entry
    text :course_code do
      id
    end
    text :short_code do
      course_code[0,6]
    end
    text :department do
      course_code[0,3]
    end
    text :collections do
      collections.map(&:name).join(" ")
    end
    text :activities do
      self["activities"] ? self["activities"].map {|a| a[1]["outcomes"].keys.join(" ")} : ""
    end
    text :blah do
      "foo"
    end
  end
end