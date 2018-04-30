$(document).ready(function(){
  
  
    $('UL.uploads LI').click(
      function(e) {
        var link = $(this).children('A').first();
        if (link != null && e.target.tagName != "A")
        {
          window.location.href = link.attr('href');
        }
      });
    
});
