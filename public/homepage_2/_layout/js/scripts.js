(function($){	
	
	// -------------------------------------------------------------------------------------------------------
	// Form Validation script - used by the Contact Form script
	// -------------------------------------------------------------------------------------------------------
	
	function validateMyAjaxInputs() {

		$.validity.start();
		// Validator methods go here:
		$("#name").require();
		$("#email").require().match("email");
		$("#subject").require();	

		// End the validation session:
		var result = $.validity.end();
		return result.valid;
	}

	$(document).ready(function(){
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////						   
		
		// -------------------------------------------------------------------------------------------------------
		// Dropdown Menu
		// -------------------------------------------------------------------------------------------------------
		
		$("ul#dropdown-menu li").hover(function () {
												 
			$(this).addClass("hover");
			$('ul:first', this).css({visibility: "visible",display: "none"}).slideDown(200);
		}, function () {
			
			$(this).removeClass("hover");
			$('ul:first', this).css({visibility: "hidden"});
		});
		
		if ( ! ( $.browser.msie && ($.browser.version == 6) ) ){
			$("ul#dropdown-menu li ul li:has(ul)").find("a:first").addClass("arrow");
		}
		
		// -------------------------------------------------------------------------------------------------------
		// Back to Top
		// -------------------------------------------------------------------------------------------------------
		
		$('a.back-top').click(function(){
			 $('html, body').animate({scrollTop: '0px'}, 600);
			 return false;
		});
		
		// -------------------------------------------------------------------------------------------------------
		// Contact Form 
		// -------------------------------------------------------------------------------------------------------
		
		$("#contact-form").submit(function () {
											
			if (validateMyAjaxInputs()) { //  procced only if form has been validated ok with validity
				var str = $(this).serialize();
				$.ajax({
					type: "POST",
					url: "_layout/php/send.php",
					data: str,
					success: function (msg) {
						$("#formstatus").ajaxComplete(function (event, request, settings) {
							if (msg == 'OK') { // Message Sent? Show the 'Thank You' message
								result = '<div class="successmsg">Your message has been sent. Thank you!</div>';
							} else {
								result = msg;
							}
							$(this).html(result);
						});
					}
		
				});
				return false;
			}
		});
			
		// -------------------------------------------------------------------------------------------------------
		// Protfolio Fade 
		// -------------------------------------------------------------------------------------------------------
		
		if ($.browser.msie && $.browser.version < 7) return;

			$(".portfolio-item-preview img").fadeTo(1, 1);
			$(".portfolio-item-preview img").hover(
			
			function () {
				$(this).fadeTo("fast", 0.80);
			}, function () {
				$(this).fadeTo("slow", 1);
			});

	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	});
	
})(window.jQuery);	

// non jQuery scripts below