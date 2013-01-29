(function($) {
	
$.fn._fadeIn = $.fn.fadeIn;
$.fn.fadeIn = function(speed, callback) {
	if ( $.support.opacity ) {
		this._fadeIn.apply(this, arguments);
	} else {
		this.show();
		callback = $.isFunction(callback) && callback || $.isFunction(speed) && speed;
		if ( callback )
			this.each(function() {
				callback.call(this);
			});
	}
	return this;
};

$.fn._fadeOut = $.fn.fadeOut;
$.fn.fadeOut = function(speed, callback) {
	if ( $.support.opacity ) {
		this._fadeOut.apply(this, arguments);
	} else {
		this.hide();
		callback = $.isFunction(callback) && callback || $.isFunction(speed) && speed;
		if ( callback )
			this.each(function() {
				callback.call(this);
			});
	}
	return this;
};

$.fn._fadeTo = $.fn.fadeTo;
$.fn.fadeTo = function(speed, to, callback) {
	if ( $.support.opacity )
		this._fadeTo.apply(this, arguments);
	else {
		callback = $.isFunction(callback) && callback || $.isFunction(speed) && speed;
		if ( to === 0 )
			this.css('visibility', 'hidden');
		else if ( to > 0 )
			this.css('visibility', 'visible');
		if ( callback )
			this.each(function() {
				callback.call(this);
			});
	}
	return this;
};

})(jQuery);