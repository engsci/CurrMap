// Create the tooltips only on document load

$(document).ready(function() 
{
   // Notice the use of the each method to gain access to each element individually
   $('.resource_icon').each(function()
   {
      var img_width, img_url;
      var img_hash = $(this).attr('rel');
      
      img_url = img_hash.split("##")[0];
      img_width = img_hash.split("##")[1];
      
      var content = '<div><img src="';
      content += img_url;
      content += '" alt="Loading thumbnail..."/></div>';
      // Setup the tooltip with the content
      $(this).qtip(
      {
         content: content,
         position: {
            corner: {
               tooltip: 'leftMiddle',
               target: 'rightMiddle'
            }
         },
         style: {
            tip: true, // Give it a speech bubble tip with automatic corner detection
            name: 'cream',
            width: img_width.to_i + 55
         }
      });
   });
   
   $('.ocw_link').each(function()
   {
      var description = $(this).attr('rel');
      
      var content = '<div>';
      content += description;
      content += '</div>';
      // Setup the tooltip with the content
      $(this).qtip(
      {
         content: content,
         position: {
            corner: {
               tooltip: 'rightMiddle',
               target: 'leftMiddle'
            }
         },
         style: {
            tip: true, // Give it a speech bubble tip with automatic corner detection
            name: 'cream',
            width: 400
         }
      });
   });
});

