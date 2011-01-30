<script type="text/javascript">
// Create the tooltips only on document load
$(document).ready(function() 
{
   // Notice the use of the each method to gain access to each element individually
   $('img.resource_icon').each(function()
   {
      // Create image content using websnapr thumbnail service
      var content = '<img src="';
      content += $(this).attr('ref');
      content += '" alt="Loading thumbnail..."/>';
      
      // Setup the tooltip with the content
      $(this).qtip(
      {
         content: content,
         position: {
            corner: {
               tooltip: 'bottomMiddle',
               target: 'topMiddle'
            }
         },
         style: {
            tip: true, // Give it a speech bubble tip with automatic corner detection
            name: 'cream'
         }
      });
   });
});
</script>
