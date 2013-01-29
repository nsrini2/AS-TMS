/*! Copyright (c) 2009 Brandon Aaron (http://brandonaaron.net)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) 
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 */

(function($) {

$.fn.extend({
	expandable: function(options) {
		options = $.extend({ duration: 'normal', interval: 750, within: 1, by: 2 }, options);
		return this.filter('textarea').each(function() {
			var $this = $(this).css({ display: 'block', overflow: 'hidden' }), minHeight, heightDiff, interval,
				rowSize = ( parseInt($this.css('lineHeight'), 10) || parseInt($this.css('fontSize'), 10) ),
				$div = $('<div style="position:absolute;top:-999px;left:-999px;border-color:#000;border-style:solid;visibility:hidden;overflow-x:hidden;z-index:0;" />').appendTo('body');
			$.each('borderTopWidth borderRightWidth borderBottomWidth borderLeftWidth paddingTop paddingRight paddingBottom paddingLeft fontSize fontFamily fontWeight fontStyle fontStretch fontVariant wordSpacing lineHeight width'.split(' '), function(i,prop) {
				$div.css(prop, $this.css(prop));
			});
			$this
				.bind('keypress', function(event) { if ( event.keyCode == '13' ) check(); })
				.bind('focus blur', function(event) {
					if ( event.type == 'blur' ) clearInterval( interval );
					if ( event.type == 'focus' && !interval ) interval = setInterval(check, options.interval);
				});
			function check() {
				var text = $this.val(), newHeight, height, usedHeight, usedRows, availableRows;
				if ( !minHeight ) {
					minHeight = $this.height();
					heightDiff = $this[0].offsetHeight - minHeight;
				}
				$div.html( text.replace(/\n/g, '&nbsp;<br>') );
				height = $this[0].offsetHeight - heightDiff;
				usedHeight = Math.max($div[0].offsetHeight - heightDiff, 0);
				usedRows = Math.max(Math.floor(usedHeight / rowSize), 0);
				availableRows = Math.floor((height / rowSize) - usedRows);
				
				if ( availableRows <= options.within ) {
					newHeight = rowSize * (usedRows + Math.max(availableRows, 0) + options.by);
					$this.stop().animate({ height: newHeight }, options.duration);
				} else if ( availableRows > options.by + options.within ) {
					newHeight = Math.max( height - (rowSize * (availableRows - (options.by + options.within))), minHeight );
					$this.stop().animate({ height: newHeight }, options.duration);
				}
			};
		}).end();
	}
});

})(jQuery);