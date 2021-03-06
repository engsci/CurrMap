class CourseInstance
  include Mongoid::Document
  include SexyRelations
  include Sunspot::Mongoid
  
  key :course_code, :delivered_year
  
  field :course_code, :type => String
  field :delivered_year, :type => Integer
  
  attr_accessible :name, :calendar_description, :weight
  attr_accessible :contact_hours_attributes, :main_topics_attributes, :learning_objectives_attributes
  
  field :name, :type => String
  
  field :calendar_description, :type => String
  field :weight, :type => Float
  
  # EMBEDDED
  
  embeds_many :activities
  
  
  embeds_many :main_topics, :class_name => 'Topic'
  accepts_nested_attributes_for :main_topics, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  
  embeds_many :learning_objectives, :class_name => 'Objective'
  accepts_nested_attributes_for :learning_objectives, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true

  embeds_one :contact_hours, :class_name => 'ContactHours'
  accepts_nested_attributes_for :contact_hours
  
  references_and_referenced_in_many :documents
  
  # RELATIONAL
  
  references_and_referenced_in_many :resources, :index => true
  references_and_referenced_in_many :instructors, :index => true
  references_and_referenced_in_many :collections,  :index => true
  referenced_in :course,  :index => true
  
  # VALIDATIONS
  
  validates_presence_of :course_code, :delivered_year, :name, :calendar_description, :weight
  validates_format_of :course_code, :with => /[A-Za-z]{3}[0-9]{3}[HY]{1}[0-9]{1}[SFY]{1}/, :message => "must be of form ABC123H1X"
  validates_format_of :delivered_year, :with => /[0-9]{4}/, :message => "must be four digits"
  validates_numericality_of :delivered_year, :weight

  # METHODS  
  def to_s
    self.course_code + " " + self.year_span  
  end
  
  def level
    self.course_code[3,1]
  end
  
  def short_code
    self.course_code[0,6]
  end
  
  def semester
    self.course_code[8,1]
  end
  
  def year_span
    "#{self.delivered_year-1}-#{self.delivered_year}"
  end
  
  def prerequisite_courses
    self.course.prerequisite_courses
  end
  
  def postrequisite_courses
    self.course.postrequisite_courses
  end
  
  def activities_by_week_and_type
    activities_by_week_and_type = {}
    self.activities.each do |a|
      if a.week
        activities_by_week_and_type[a.week] ||= {"lectures" => [], "other" => []}
        if a.class == Lecture
          activities_by_week_and_type[a.week]["lectures"] << a
        else
          activities_by_week_and_type[a.week]["other"] << a
        end
      end
    end
    return activities_by_week_and_type
  end
  
  def activities_by_type
    activities_by_type = {}
    self.activities.each do |a|
      activities_by_type[a.class.to_s] ||= [] 
      activities_by_type[a.class.to_s] << a
    end
    return activities_by_type
  end

  # SEARCH
  
  def self.search_as_you_type(term)
    if term && term.length
      results = term.length > 1 ? CourseInstance.where(:course_code => /#{term}/i) : CourseInstance.where(:course_code => /^#{term}/i)
      return results.map {|x| {"label" => x.to_s, "id" => x._id, "value"=> x.to_s}}
    else
      return []
    end
  end
  
  searchable do
    text :name
    text :calendar_description
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
      activities.map{|a| a.topics.join(" ")}.join(" ")
    end
    text :main_topics do
      main_topics.join(" ")
    end
    text :learning_objectives do
      learning_objectives.join(" ")
    end
    text :prerequisite_topics do
      self.course.prerequisite_topics.join(" ") if self.course
    end
  end

end

# EMBEDDED MODELS

class ContactHours
  include Mongoid::Document
  
  field :lecture, :type => Float
  field :tutorial, :type => Float
  field :practical, :type => Float
  
  embedded_in :course, :inverse_of => :contact_hours
  
  validates_numericality_of :lecture, :tutorial, :practical
end

class Activity
  include Mongoid::Document
  
  attr_accessible :week, :number

  field :week, :type => Integer
  field :number, :type => Integer
  
  embedded_in :course, :inverse_of => :activities
  embeds_many :topics
end

class Session < Activity
end
class Lecture < Session
end
class Tutorial < Session
end
class Practical < Session
end
class Lab < Session
end

class Assessment < Activity
end
class ProblemSet < Assessment
end
class Project < Assessment
end
class Quiz < Assessment
end
class Midterm < Assessment
end
class Exam < Assessment
end

class Topic
  include Mongoid::Document
  
  attr_accessible :name
  
  field :name, :type => String
  
  embedded_in :course_instance, :inverse_of => :main_topics
  embedded_in :activity, :inverse_of => :topics
  
  validates_presence_of :name
  
  def to_s
    self.name
  end
end

class Objective < Topic
  embedded_in :course_instance, :inverse_of => :learning_objectives
end