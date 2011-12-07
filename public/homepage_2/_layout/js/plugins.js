(function($){
		  
	$(document).ready(function(){
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////						   
		
		// -------------------------------------------------------------------------------------------------------
		// Cufon - font replacement
		// -------------------------------------------------------------------------------------------------------
		
		if ( ! ( $.browser.msie && ($.browser.version == 6) ) ){ // only apply cufon on modern browsers
		
			Cufon.replace('h1, h2, h3, h4, h5, h6, #contact, #dropdown-menu li a', {hover: true});
		}
		
		// -------------------------------------------------------------------------------------------------------
		// DD_belated - IE6 png transparency fix
		// -------------------------------------------------------------------------------------------------------
		
		if ( $.browser.msie ){
			if ( $.browser.version == 6 ){ // only apply the png transparency fix for Internet Explorer 6
				
				DD_belatedPNG.fix('#contact-info li');
				DD_belatedPNG.fix('#logo img');
				DD_belatedPNG.fix('.errormsg, .successmsg, .infomsg, .noticemsg');
				DD_belatedPNG.fix('#slideshow-nav .prev');
				DD_belatedPNG.fix('#slideshow-nav .next');
				DD_belatedPNG.fix('.search-submit-btn, .accordion li a');
				
			}
		}
		
		// -------------------------------------------------------------------------------------------------------
		// Tipsy - facebook like tooltips jQuery plugin
		// -------------------------------------------------------------------------------------------------------
		
		$('.tip').tipsy({gravity: 'w', fade: true});
		
		// -------------------------------------------------------------------------------------------------------
		// pretyPhoto - jQuery lightbox plugin
		// -------------------------------------------------------------------------------------------------------
		
		$("a[rel^='prettyPhoto']").prettyPhoto({
			opacity: 0.80, 						// Value between 0 and 1
			default_width: 500,
			default_height: 344,
			theme: 'light_square', 				// light_rounded / dark_rounded / light_square / dark_square / facebook 
			hideflash: false, 					// Hides all the flash object on a page, set to TRUE if flash appears over prettyPhoto 
			modal: false 						// If set to true, only the close button will close the window 
		});
		
		// -------------------------------------------------------------------------------------------------------
		// Cycle - slider jQuery plugin 
		// -------------------------------------------------------------------------------------------------------
		
		$('#slideshow ul').cycle({
			timeout: 5000,						// milliseconds between slide transitions (0 to disable auto advance)
			fx:   'fade',						// choose your transition type, ex: none, fade, scrollUp, shuffle, etc... 
			prev: '#slideshow-nav .prev',		// selector for element to use as click trigger for next slide  
			next: '#slideshow-nav .next',		// selector for element to use as click trigger for previous slide
			delay: 0,      						// additional delay (in ms) for first transition (hint: can be negative)
			speed: 600,  						// speed of the transition (any valid fx speed value) 
			pause: 0,							// true to enable "pause on hover"
			cleartypeNoBg: true,				// set to true to disable extra cleartype fixing (leave false to force background color setting on slides) 
			pauseOnPagerHover: 0 				// true to pause when hovering over pager link
		});
		
		$('#portfolio-item-preview-slideshow ul').cycle({
			timeout: 0,// milliseconds between slide transitions (0 to disable auto advance)
			fx: 'fade',// choose your transition type, ex: fade, scrollUp, shuffle, etc... 
			prev: '#portfolio-item-preview-slideshow-prev',// selector for element to use as click trigger for next slide  
			next: '#portfolio-item-preview-slideshow-next',// selector for element to use as click trigger for previous slide
			delay: 0,      // additional delay (in ms) for first transition (hint: can be negative)
			speed: 1000,  // speed of the transition (any valid fx speed value) 
			pause: 0,// true to enable "pause on hover"
			cleartypeNoBg: true,// set to true to disable extra cleartype fixing (leave false to force background color setting on slides) 
			pauseOnPagerHover: 0 // true to pause when hovering over pager link
		});
		
		// -------------------------------------------------------------------------------------------------------
		//  Tabify - jQuery tabs plugin
		// -------------------------------------------------------------------------------------------------------
		
		//$('#tab-1').tabify();
		
		// -------------------------------------------------------------------------------------------------------
		//  Accordeon - jQuery accordeon plugin
		// -------------------------------------------------------------------------------------------------------
		
		//$('#accordion-1').accordion();

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	});

})(window.jQuery);

// non jQuery plugins below

