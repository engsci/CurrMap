class Course
  include Mongoid::Document
  include SexyRelations
  
  key :course_code
  
  field :course_code, :type => String
  
  attr_accessible :course_code, :name
  
  field :name, :type => String
  
  references_and_referenced_in_many :collections, :index => true
  references_many :course_instances, :inverse_of => :course, :index => true
  
  # VALIDATIONS
  
  validates_presence_of :name, :course_code
  validates_format_of :course_code, :with => /[A-Za-z]{3}[0-9]{3}/, :message => "must be of form ABC123"
  
  # METHODS
  
  def to_s
    course_code
  end
  
  def level
    self.course_code[3,1]
  end
  
  # SEARCH
  
  def self.search_as_you_type(term)
    if term && term.length
      results = term.length > 1 ? (Course.where(:name => /#{term}/i) + Course.where(:_id => /#{term}/i)).uniq  : (Course.where(:name => /^#{term}/i) + Course.where(:_id => /^#{term}/i)).uniq
      return results.map {|x| {"label" => x.to_s, "id" => x._id, "value"=> x.to_s}}
    else
      return []
    end
  end
  
  
end