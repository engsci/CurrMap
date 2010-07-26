$(document).ready(function(){
  //$('#ferret_search').focus();
  default_msg = "Search...";//$('#ferret_search').val();
  $('#ferret_search').focus(
    function() {
      if ($(this).attr('value') == default_msg) $(this).attr('value', '');
      $(this).addClass("active");
    }
  ).blur(
    function() {
      if ($(this).attr('value') == '') $(this).attr('value', default_msg);
      $(this).removeClass("active");
    }
  );
});