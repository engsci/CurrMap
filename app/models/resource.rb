class Resource
  include Mongoid::Document
  identity :type => String
  
  field :isbn, :type => String
  field :authors, :type => Array
  field :edition, :type => String #Integer
  field :name, :type => String
  field :publisher, :type => String
  field :optional, :type => Boolean
 # field :type, :type => String
  
  def author
    authors[0]
  end
  
  references_and_referenced_in_many :courses, :inverse_of => :resources, :index => true
  
  #def logger
  #  RAILS_DEFAULT_LOGGER
  #end
  
  def author
    read_attribute(:author) || "Unknown"
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
