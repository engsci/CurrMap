$(document).ready(
  function() {
    
    $('a[rel*=facebox]').facebox();

    $(".prof_name").click(
      function() {
	    $(this).next().toggle('slow');
		return false;
	  }).next().hide();
	  
    $(".activity_listing").click(
      function() {
        $(this).next().toggle();
      }).next().hide();
      
    //$(".activities").prepend("<p class=\"expand_all_activities\">Expand/Hide All</p>");
    
    $(".activities h5").bind("click",
      function(e) {
        $(e.target).siblings("dl").toggle();
      }
    );
    
    $(".activities dl").hide();
    
  });
