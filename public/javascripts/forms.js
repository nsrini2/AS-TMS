// Use HTML5 placeholders when possible, else us JS to do the same
function supports_input_placeholder() { var i = document.createElement('input'); return 'placeholder' in i; }
      
(function($) {  // $ = jQuery within this block
	$(document).ready(function() {  
			$(document).find('form.html5').setup_html5_form().end();
	  
	  // MM2: Basically recreate the html5 placeholder functionality for browsers that don't
	  if(!supports_input_placeholder()) {  	  
      var inputs = 'form.labeless input:text, form.labeless input:password, form.labeless textarea';

      $(inputs).each(function(element) {
        $this = $(this);
        if($this.attr('value') == '') {
          $this.attr('value', $this.attr('placeholder'));
    		  $this.addClass('placeholder');
        }
  		}),

      $(inputs).live('click', function(event) {
        $this = $(this);
        if($this.attr('value') == $this.attr('placeholder')) {
    		  $this.attr('value','');
    		  $this.removeClass('placeholder');
    		  return false;
        }
  		}),
	
  		$(inputs).bind('blur', function(event) {
  		  $this = $(this);
  		  if($this.attr('value') == '') {
  		    $this.attr('value', $this.attr('placeholder'));
  		    $this.addClass('placeholder');
  		  }
  		});
  		
      // Clear out placeholders before submit
      $(inputs).parents('form').submit(function() {
                $(this).find('input.placeholder').each(function() {
                  var input = $(this);
                  if (input.val() == input.attr('placeholder')) {
                    input.val('');
                  }
                })
              }); 
	  }
  });
})(jQuery);