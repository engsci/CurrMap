$(document).ready(
  function() {
    $(".prof_name").click(
      function() {
	    $(this).next().toggle('slow');
		return false;
	  }).next().hide();
    $(".activity_listing").click(
      function() {
        $(this).next().toggle();
      }).next().hide();
    $(".activities").prepend("<p class=\"expand_all_activities\">Expand All</p>");
    $(".expand_all_activities").click(
      function() {
        $(".activity_listing").next.show();
      }
    );
  });