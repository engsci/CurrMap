class Person
  include Mongoid::Document
  
  key :slug
  
  field :slug, :type => String
  
  attr_accessible :name
  
  field :name, :type => String 
  
  # METHODS
  
  def to_s
    self.name
  end
  
  # SEARCH
  
  def self.search_as_you_type(term)
    if term && term.length
      results = term.length > 1 ? Person.where(:name => /#{term}/i) : Person.where(:name => /^#{term}/i)
      return results.map {|x| {"label" => x.name, "id" => x._id, "value"=> x.name}}
    else
      return []
    end
  end
  
  if false
    include Sunspot::Mongoid
    searchable do
      text :name
      text :course_descriptions do
        self.courses.map(&:calendar_description).join(" ")
      end
      text :course_names do 
        self.courses.map(&:name).join(" ")
      end
    end
  end

end

class Instructor < Person
  
  attr_accessible :phone, :website, :email
  
  field :phone, :type => String
  field :website, :type => String
  field :email, :type => String

  
  references_and_referenced_in_many :course_instances, :index => true
  
  def years_taught
    self.course_instances.map{|x| x.delivered_year}.uniq.sort
  end
end
