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
    #quick check for inconsistent database naming
    isbn = read_attribute(:isbn) 
    isbn ||= read_attribute(:ISBN)
    info = nil
    unless isbn.nil?
      amz_search = AmazonSearch.new
      response  = amz_search.lookup(isbn, {:IdType=>'ISBN', :SearchIndex=>'Books', :ResponseGroup=>'Reviews,Images,ItemAttributes'})
      #Build a Hashie object to return
      unless response.raw.DetailPageURL.nil?
        info = Hashie::Mash.new
        info.URL = response.raw.DetailPageURL
        info.attributes = response.raw.ItemAttributes
        info.images!.small = response.raw.SmallImage
        info.images!.medium = response.raw.MediumImage
        info.images!.large = response.raw.LargeImage
        return info
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

class AmazonSearch
  include ASIN
  require 'asin'
   #Amazon Web Services private keys
   #set to credentials via Valentin Peretroukhin, valentinp@gmail.com
  def initialize
    self.configure_asin({:secret => 'BQFecPgPmogzZHGunvwFEr7gTwaDCLiu+8Anx8Xh', 
                        :key => 'AKIAILOZ2RM5V4SATVZQ', 
                        :host => 'webservices.amazon.ca'})
            
  end
end
