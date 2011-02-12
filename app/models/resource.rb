class Resource
  include Mongoid::Document
  include SexyRelations

  attr_accessible :name, :optional
  
  field :name, :type => String
  field :optional, :type => Boolean
  
  validates_presence_of :name
  
  references_and_referenced_in_many :course_instances, :index => true
  
  # METHODS
  
  def to_s
    name
  end
  
  def amazon_info
    r_info = nil
    
    unless isbn.nil?
      amz_search = ASIN.client
      amz_response  = amz_search.lookup(isbn, {:IdType=>'ISBN', :SearchIndex=>'Books', :ResponseGroup=>'Reviews,Images,ItemAttributes'})
      #Build a Hashie object to return
      unless amz_response.raw.DetailPageURL.nil?
        r_info = Hashie::Mash.new
        r_info.URL = amz_response.raw.DetailPageURL
        r_info.attributes = amz_response.raw.ItemAttributes
        r_info.images!.small = amz_response.raw.SmallImage
        r_info.images!.medium = amz_response.raw.MediumImage
        r_info.images!.large = amz_response.raw.LargeImage
        return r_info
      end
    end
  end

  
  # SEARCH
  
  def self.search_as_you_type(term)
    if term && term.length
      results = term.length > 1 ? Resource.where(:name => /#{term}/i) : Resource.where(:name => /^#{term}/i)
      return results.map {|x| {"label" => x.name, "id" => x._id, "value"=> x.name}}
    else
      return []
    end
  end
  
  if false
    include Sunspot::Mongoid
    searchable do
      text :publisher
      text :name
      text :authors do 
        self.authors ? self.authors.join(" ") : nil
      end
      text :isbn
    end  
  end
  
end

# TYPES

class Textbook < Resource  
  attr_accessible :isbn, :edition, :publisher, :authors_attributes
  
  field :isbn, :type => String
  field :edition, :type => String
  field :publisher, :type => String
  
  embeds_many :authors
  accepts_nested_attributes_for :authors, :reject_if => proc { |attributes| attributes['name'].blank? }
end

# EMBEDDED

class Author
  include Mongoid::Document
  
  attr_accessible :name
  
  field :name, :type => String
  
  validates_presence_of :name
  
  embedded_in :textbook
  
  def to_s
    self.name
  end
end