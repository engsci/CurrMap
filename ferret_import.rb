#!/usr/bin/env ruby
require 'rubygems'
require 'couchrest'
require 'ferret'

include Ferret

@index = Index::Index.new(:path => 'ferret', :analyzer => Analysis::StandardAnalyzer.new)

def recursive_store(hash, target)
  hash.each do |k,v|
    if k == "outcomes"
      target[k.to_sym] = v.to_a.join(" ")
    elsif v.kind_of? String
      target[k.to_sym] = v if k != ""
    elsif v.kind_of? Array
      target[k.to_sym] = v.join(" ")  if k != ""
    elsif v.kind_of? Hash
      recursive_store(v, target)
    end
  end
  return nil
end

def dbparse(source)
  return case source.class
    when Array then
      source.join(" ")
    when String then
      source
    when Hash then
      source
    else
      source
  end
end

@db = CouchRest.database("http://127.0.0.1:5984/currmap")
@db.view('testing/All')['rows'].each do |doc|
  parsed_doc = {}
  
  parsed_doc["id"] = doc["id"]
     
  case doc["value"]["class"]
    when "Resource" then
      parsed_doc["author"] = dbparse doc["value"]["author"]
      parsed_doc["name"] = dbparse doc["value"]["name"]
      parsed_doc["publisher"] = dbparse doc["value"]["publisher"]
    when "Person" then
      parsed_doc["name"] = dbparse doc["value"]["name"]
    when "Collection" then
      parsed_doc["courses"] = dbparse doc["value"]["courses"]
      parsed_doc["collections"] = dbparse doc["value"]["collections"]
    when "Course" then
      parsed_doc["name"] = dbparse doc["value"]["name"]
      parsed_doc["calendar_entry"] = dbparse doc["value"]["calendar_entry"]
      parsed_doc["outcomes"] = doc["value"]["activities"].values.map {|v| v["outcomes"].keys }.join(" ") if doc["value"]["activities"]
  end

  parsed_doc["content"] = parsed_doc.values.join(" ")  
  parsed_doc["class"] = doc["value"]["class"]
 
  @index << parsed_doc
end
