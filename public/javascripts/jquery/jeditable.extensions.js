(function($) {

$.editable.addInputType('expandable', {
	element : $.editable.types.textarea.element,
	plugin : function(settings, original) {
		var $textarea = $('textarea', this);
		$textarea.val($textarea.val().replace(/<br>/gi, '\n').replace(/<\/?[^>]+>/gi, ''));
		$textarea.expandable({ by: 1 }).attr('maxlength', settings.maxlength);
	}
});

$.editable.types.textarea.plugin = function(settings, original) {
	$('textarea', this).attr('maxlength', settings.maxlength);
};

$.editable.types.text.plugin = function(settings, original) {
	$('input[type=text]', this).attr('maxlength', settings.maxlength);
};

})(jQuery);