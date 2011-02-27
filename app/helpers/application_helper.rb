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
  
  def course_instance_path(course_instance)
    return polymorphic_path([course_instance.course, course_instance])
  end
  
  def course_course_instance_path(course, course_instance)
    url_for({:controller => "course_instances", :action => "show", :id => course_instance, :course_id => course})
  end
  
  
  def file_uploadify(object)
    session_key_name = Rails.application.config.session_options[:key]
    %Q{

    <script type='text/javascript'>
      $(document).ready(function() {
        $('.file_upload').uploadify({
          script          : '#{documents_path}',
          fileDataName    : 'document[file]',
          uploader        : '/uploadify/uploadify.swf',
          cancelImg       : '/uploadify/cancel.png',
          fileDesc        : 'Files',
          fileExt         : '*.pdf',
          sizeLimit       : #{10.megabytes},
          queueSizeLimit  : 24,
          multi           : true,
          auto            : true,
          buttonText      : 'Add Files',
          scriptData      : {
            '_http_accept': 'application/javascript',
            '#{session_key_name}' : encodeURIComponent(encodeURIComponent('#{u(cookies[session_key_name])}')),
            'authenticity_token'  : encodeURIComponent(encodeURIComponent('#{u(form_authenticity_token)}'))
          },
          onComplete      : function(a, b, c, response){ eval(response) }
        });
      });
    </script>

    }.gsub(/[\n ]+/, ' ').strip.html_safe
  end
end
