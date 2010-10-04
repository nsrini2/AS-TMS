$(document).ready(function($) {
	var $div = $('<div style="height: 1px; min-height: 2px; position: absolute; top: -100px; left: -100px;"/>').appendTo('body');
	$.support.minHeight = !!( $div[0].offsetHeight && $div[0].offsetHeight == 2 );
	$div.remove();
});