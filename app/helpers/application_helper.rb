module ApplicationHelper
  def activity_type(code)
    type = code
    type = "lecture" if code =~ /^L\d+/
    type = "midterm" if code =~ /^MT\d+/
    type = "tutorial" if code =~ /^T\d+/
    type = "pset" if code =~ /^PS\d+/
    type = "assignment" if code =~ /^A\d+/
    type = "project" if code =~ /^PROJ\d+/
    return type
  end
  
  def topic_path(topic)
    url_for(:controller => "pages", :action => "search", :query => topic.name)
  end
  
  def objective_path(obj)
    topic_path(obj)
  end
end
