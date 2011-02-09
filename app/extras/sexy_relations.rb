module SexyRelations
  # receive check_boxes attributes from formtastic and save to mongoid
  # may be made useless if mongoid is changed to deal properly with attributes (ex. params[:course][:instructor_ids])
  # at the moment, if course.instructor_ids is modified, mongoid does not detect and modify the instructor side
    
  # override and 
  def update_attributes(attributes)
    self.attributes = attributes
    if save
      # get the habtm relations of this class, ex. [:instructors, :collections, :resources]
      many_to_many_refs = self.class.relations.values.map{|v| v.name if v.macro == :references_and_referenced_in_many}.compact
      self.update_relations(attributes, many_to_many_refs)
    end
  end
  
  # receives for ex. (params[:course], [:instructors, :collections])
  def update_relations(params, array_of_relations)
    array_of_relations.each do |relation|
      # drop(1) because the formtastic makes the first element ""
      attributes = params[relation.to_s.singularize + "_ids"].drop(1)
      update_relation(params[relation.to_s.singularize + "_ids"].drop(1), relation) if attributes.length > 0
    end
  end
  
  def update_relation(array_of_ids, relation)
    new_relations = array_of_ids.map {|i| relation.to_s.classify.constantize.where(:_id => i).limit(1)[0]}
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