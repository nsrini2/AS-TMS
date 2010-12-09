(function($) {  // $ = jQuery within this block
  
	$(document).ready(function() {

		$('.alert a#system_admin_close').live('click', function(event) {
		  $this = $(this);
		  
		  $.cookie("system_announcement_updated_at", $this.attr('updatedat'), { expires: 300 })
		  
		  $this.parent().fadeTo('slow', 0.01, function(){$(this).slideUp();});
		  return false;
		}),

		$('.alert .close').live('click', function(event) {
		  $(this).parent().fadeTo('slow', 0.01, function(){$(this).slideUp();});
		  return false;
		}),
		
		$('div.tabs ul.tabs-nav li a').live('click', function(event) {
			var $this = $(this);

      // Allow for standard tabs
      if($this.parent().parent().hasClass('standard')) {
        window.location = $this.attr('href');
      }
      else {
  			// Toggle the tab links
  			$('.tabs ul.tabs-nav li').removeClass('active');
  			$this.parent().addClass('active');

  			// Toggle the tab containers
  			$('div.tabs-panel').hide();
  			$('div' + $this.attr('href')).show();

  			return false;
  		}
		}),


		// Special hub behavior

		
    // $('input#status_question').live('click', function(event) {
    //   $this = $(this);
    //   
    //   $form = $('form#widget_status');
    //   
    //   if($this.attr('checked')) {
    //     $form.attr('action', '/questions');
    //     $('select#status_question_category').show();
    //     
    //     $('textarea#status_body').attr('maxlength', '4000');
    //   }
    //   else {
    //     $form.attr('action', '/statuses');
    //     $('select#status_question_category').hide();
    //     
    //     $('textarea#status_body').attr('maxlength', '140');
    //   }
    // }),

		$('#ask textarea#status_body').click(function(event) {
		  $this = $(this);
		  $this.removeClass('ask_text_placeholder');
		}),
		$('#ask textarea#status_body').bind('blur', function(event) {
		  $this = $(this);
		  if($this.val() == "" || $this.val() == $this.attr('placeholder')) {
		    $this.addClass('ask_text_placeholder');
	    }
		}),
		
		// Do hiding/showing tabs via url parts on the hub page
		$('div.tabs').each(function(){
		  $this = $(this);
		  
		  var urlHash = window.location.hash;
		  var urlPathname = window.location.pathname;
		  if((urlPathname == "/" || urlPathname == "/profiles/hub") && urlHash && $this.has('div' + urlHash)) {    		    
		    // Set all tabs to not be active and hidden
		    $this.find('ul.tabs-nav li').removeClass('active');
		    $this.find('div.tabs-panel').hide();
		    
		    // Make the match active and visible
		    $this.find('ul.tabs-nav li a[href=' + urlHash + ']').parent().addClass('active');
		    $this.find('div' + urlHash).show();
		  }
		  
		});
	});
	
	$.fn.extend({    	
  	// Status
  	update_status_widget: function(data) {
  		$('#status_body').val("");
  		
  		// More than just reload...clear out all the values
  		// window.location.reload();
  		window.location = window.location;
  	}
  });
})(jQuery);  