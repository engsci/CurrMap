class CourseInstance
  include Mongoid::Document
  include SexyRelations
  
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
  
  def collated_activities
    collated_activities = {}
    self.activities.each do |a|
      collated_activities[a.week || 0] ||= {"lectures" => [], "other" => []}
      if a.class == Lecture
        collated_activities[a.week || 0]["lectures"] << a
      else
        collated_activities[a.week || 0]["other"] << a
      end
    end
    return collated_activities
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
class Assignment < Activity
end
class ProblemSet < Assignment
end
class Project < Assignment
end
class Evaluation < Activity
end
class Quiz < Evaluation
end
class Midterm < Evaluation
end
class Exam < Evaluation
end

class Topic
  include Mongoid::Document
  
  attr_accessible :name
  
  field :name, :type => String
  
  embedded_in :course_instance, :inverse_of => :main_topics
  embedded_in :activity, :inverse_of => :topics
  embedded_in :course, :inverse_of => :prerequisite_topics
  
  validates_presence_of :name
  
  def to_s
    self.name
  end
end

class Objective < Topic
  embedded_in :course_instance, :inverse_of => :learning_objectives
end