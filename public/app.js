$(document).ready(
  function() {

    //adds facebox links to main content
    $('a[rel*=facebox]').facebox();

    //adds facebox links to content loaded into facebox
    $(document).bind('reveal.facebox',
      function() {
        $('#facebox a[rel*=facebox]').facebox();
      }
    );

	  /*
    $(".activity_listing").click(
      function() {
        $(this).next().toggle();
      }
    ).next().hide();
   */

    $(".show_activities").bind("click",
      function(e) {
        $(e.target).parent().siblings('.activities').toggle();
      }
    );

    $('#ferret_search').focusin(
      function() {
        if ($('#ferret_search').attr('value') == 'Search') {
          $('#ferret_search').attr('value', '');
        }
      }
    ).focusout(
      function() {
        if ($('#ferret_search').attr('value') == '') {
          $('#ferret_search').attr('value', 'Search');
        }
      }
    );
  }
);