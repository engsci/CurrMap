// Create the tooltips only on document load

$(document).ready(function() 
{
   // Notice the use of the each method to gain access to each element individually
   $('.resource_icon').each(function()
   {
      // Create image content using websnapr thumbnail service
      var content = '<div><img src="';
      content += $(this).attr('rel');
      
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
            name: 'cream'
         }
      });
   });
});

