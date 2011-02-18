module SexyRelations
  # receive check_boxes attributes from formtastic and save to mongoid
  # may be made useless if mongoid is changed to deal properly with attributes (ex. params[:course][:instructor_ids])
  # at the moment, if course.instructor_ids is modified, mongoid does not detect and modify the instructor side
  def self.included( klass )  
  end
  
  # override and 
  def update_attributes(attributes)
    self.attributes = attributes
    if save
      self.update_relations(attributes)
    end
  end
  
  # receives for ex. (params[:course])
  def update_relations(params)
    # get the habtm relations of this class, ex. [:instructors, :collections, :resources]
    array_of_relations = self.class.relations.values.map{|v| v.name if v.macro == :references_and_referenced_in_many}.compact
    
    array_of_relations.each do |relation|
      # drop(1) because the formtastic makes the first element ""
      attributes = params[relation.to_s.singularize + "_ids"]
      update_relation(attributes.drop(1), relation) if attributes && attributes.length > 1
    end
  end
  
  def update_relation(array_of_ids, relation)
    relation_class = self.reflect_on_association(relation).class_name.classify.constantize
    new_relations = array_of_ids.map {|i| relation_class.where(:_id => i).limit(1)[0]}
    current_relations = self.send(relation)
    
    # remove old ones
    (current_relations - new_relations).each do |r|
       self.send(relation).delete(r)
       r.save
    end
    
    self.save
    
    # add new ones
    (new_relations - current_relations).each do |r|
      self.send(relation) << r
      r.save
    end
    
  end
  
end

module Sunspot
  module Rails
    module Searchable
      module ActsAsMethods
        def searchable(options = {}, &block)
          Sunspot.setup(self, &block)

          if self.respond_to?(:sunspot_options) && sunspot_options
            sunspot_options[:include].concat(Util::Array(options[:include]))
          else
            extend ClassMethods
            include InstanceMethods

            class_inheritable_hash :sunspot_options

            unless options[:auto_index] == false
              before_save :maybe_mark_for_auto_indexing
              after_save :maybe_auto_index
            end

            unless options[:auto_remove] == false
              after_destroy do |searchable|
                searchable.remove_from_index
              end
            end
            options[:include] = Util::Array(options[:include])

            self.sunspot_options = options
          end
        end
      end
    end
  end
end