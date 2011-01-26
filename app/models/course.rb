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
  field :main_topics, :type => Array
  #workload for lecture, tutorial, practice
  
  #field :workload, :type => Hash
  embeds_one :workload
  accepts_nested_attributes_for :workload
  #accepts_nested_attributes_for :main_topics
  
  # RELATIONSHIPS
  # embeds_many :activities
  references_and_referenced_in_many :resources, :inverse_of => :courses, :index => true
  references_and_referenced_in_many :professors, :inverse_of => :courses, :index => true
  references_and_referenced_in_many :collections,  :inverse_of => :courses, :index => true
  
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
  
  
  def self.find_course(course_code, year)
    Course.where(:course_code => /^#{course_code}/, :year => year).limit(1)[0]
  end
  
  # METHODS  
  def name
	  return read_attribute(:name) ? read_attribute(:name).split(" - ")[0] : nil
  end

  def year
    return self.course_code[3,1]
  end
  
  def year_version
    return read_attribute(:year)
  end
  
  def short_code
    return self.course_code[0,6]
  end
  
  def available_years
    Course.where(:course_code => /^#{self.short_code}/).map {|c| c.year_version }
  end
  
  
  def lectures
    self.activities.find_all{|a| a.class == Lecture}
  end
  
  def midterms
    self.activities.find_all{|a| a.class == Midterm}
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
    text :course_code
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
    text :main_topics do
      self["main_topics"] ? self["main_topics"].join(" ") : ""
    end
  end
end

class Workload
  include Mongoid::Document
  
  field :lecture
  field :tutorial
  field :practical
  embedded_in :course, :inverse_of => :workload
end
