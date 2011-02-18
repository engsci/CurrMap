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

  attr_accessible :isbn, :edition, :publisher, :authors_attributes, :amazon_info
  
  field :isbn, :type => String
  field :edition, :type => String
  field :publisher, :type => String
  
  embeds_many :authors
  accepts_nested_attributes_for :authors, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  
  def amazon_info
    require 'amazon/ecs'
    require 'hashie'
    
    Amazon::Ecs.configure do |options|
        options[:aWS_access_key_id] = 'AKIAILOZ2RM5V4SATVZQ'
        options[:aWS_secret_key] = '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'
    end
    

    
    r_info = self.isbn   
    unless self.isbn.nil?
      r_info = amzq = Amazon::Ecs.item_search(self.isbn, {:ResponseGroup=>'Reviews,Images,ItemAttributes'})
      tbook = amzq.first_item
      #Build a Hashie object to return
      unless tbook.nil?
        r_info = Hashie::Mash.new
        r_info.URL = tbook.get('detailpageurl')
        r_info.attributes = Hashie::Mash.new(tbook.get_hash('itemattributes'))
        r_info.attributes!.formattedprice = tbook.get('itemattributes/listprice/formattedprice')
        r_info.images!.small = Hashie::Mash.new(tbook.get_hash('smallimage'))
        r_info.images!.medium = Hashie::Mash.new(tbook.get_hash('mediumimage'))
        r_info.images!.large = Hashie::Mash.new(tbook.get_hash('largeimage'))
        return r_info
      end
    end
    
    r_info
 
  
  end
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
