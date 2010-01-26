#!/usr/bin/env ruby
require 'rubygems'
require 'ferret'

include Ferret

@searcher = Search::Searcher.new('ferret')
@index = Index::Index.new(:path => 'ferret', :analyzer => Analysis::WhiteSpaceAnalyzer.new)

unless ARGV.empty?
  field = ARGV[0].to_sym
  term = ARGV[1]

  query = Search::FuzzyQuery.new(ARGV[0], ARGV[1], :prefix_length => 2)
  @searcher.search_each(query) do |id, score|
    puts "Document #{id} found with a score of #{score}"
    puts @index[id].load.inspect
   puts @searcher.highlight(query, 0,
                       ARGV[0],
                       :pre_tag => "~",
                       :post_tag => "~",
                       :excerpt_length => :all) if false
  end
  
end

