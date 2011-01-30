$.extend({
  //get URL vars function
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


//set ajax requests as js type instead of html
jQuery(document).ajaxSend(function(event, request, settings) {
  request.setRequestHeader("Accept", "text/javascript");
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  if (settings.type.toUpperCase() == 'GET' || typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  if (typeof(AUTH_TOKEN) != "undefined")
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});


jQuery.fn.highlight_terms = function(){
  var o = $(this[0])
  
  //highlight search term    
  var query = $.getUrlVar('query');
  
  if(query) {
    terms = query.split('+');
    for(x in terms){
      o.highlight(terms[x]);
    }
  }
}
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

   //add tabs
   $(".mini-tabs").tabs();
   $("#tabs").tabs({
     cache: true,
     spinner: 'Retrieving data...',
     ajaxOptions: {
       error: function(xhr, status, index, anchor) {
         $(anchor.hash).html("Request Failed.");
       }
   	 },
   	 load: function(event,ui){
   	   //facebox ajax content
   	   $('#'+ui.panel.id+' a[rel*=facebox]').facebox();
   	   $('#main').highlight_terms();
   	 }
   });
   
   $('#main').highlight_terms();
  
    
  }
);
