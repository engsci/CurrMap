$.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});

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
    
    //highlight search term
    
    var query = $.getUrlVar('query');
    
    if(query)
      $('body').highlight(query);
  }
);
