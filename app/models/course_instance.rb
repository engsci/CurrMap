class CourseInstance
  include Mongoid::Document
  
  key :course_code, :delivered_year
  
  field :course_code, :type => String
  field :delivered_year, :type => Integer
  
  attr_accessible :name, :calendar_description, :weight, :contact_hours_attributes
  
  field :name, :type => String
  
  field :calendar_description, :type => String
  field :weight, :type => Float
  
  # EMBEDDED
  
  embeds_many :activities
  embeds_many :main_topics, :class_name => 'Topic'
  accepts_nested_attributes_for :main_topics

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
  
  # needed for formtastic to work :@
  def instructor
    instructors
  end
  
  def update_instructors(array_of_ids)
    new_instructors = array_of_ids.drop(1).map {|i| Instructor.where(:_id => i)[0]}
    current_instructors = self.instructors
    # remove old ones
    (current_instructors - new_instructors).each do |i|
      self.instructors.delete(i)
      self.save
      i.save
    end
    # add new ones
    (new_instructors - current_instructors).each do |i|
      self.instructors << i
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
  
  embedded_in :course, :inverse_of => :main_topics
  embedded_in :activity, :inverse_of => :topics
  
  validates_presence_of :name
  
  def to_s
    self.name
  end
end