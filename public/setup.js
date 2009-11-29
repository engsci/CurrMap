$(document).ready(
  function() {
    
    $('a[rel*=facebox]').facebox();
   
    $(document).bind('reveal.facebox', 
      function() { 
        $('#facebox a[rel*=facebox]').facebox();
      }
    );
	  
    $(".activity_listing").click(
      function() {
        $(this).next().toggle();
      }
    ).next().hide();      
    
    $(".activities h5").bind("click",
      function(e) {
        $(e.target).siblings("dl").toggle();
      }
    );
    
    $(".activities dl").hide();
    
  }
);
