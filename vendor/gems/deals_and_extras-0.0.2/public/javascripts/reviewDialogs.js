$(function() {
	addViewReviewListener();
	addWriteReviewListener();
	addLoginListenerExample();

});

function addWriteReviewListener() {

	$('#review_write_dialog').dialog({
		autoOpen : false,
		modal : true,
		width : 700,
		height : 600
	});

	$('#search_deals li').each(function(index) {

		var $thumbs_up = $(this).find('img.deal_thumbs_up');
		var $thumbs_down = $(this).find('img.deal_thumbs_down');
		var $write_review = $(this).find('.deal_write_review');
		$thumbs_up.click(function() {
			jQuery("#review_write_dialog").dialog('open');
			return false;
		});

		$thumbs_down.click(function() {
			jQuery("#review_write_dialog").dialog('open');
			return false;
		});

		$write_review.click(function() {
			jQuery("#review_write_dialog").dialog('open');
			return false;
		});
	});
}

function addViewReviewListener() {
	$('#review_view_dialog').dialog({
		autoOpen : false,
		modal : true,
		width : 700,
		height : 600
	});

	$('#search_deals li').each(function(index) {

		var $viewReviews = $(this).find('.deal_view_reviews');
		$viewReviews.click(function() {
		    alert("hi");
			jQuery("#review_view_dialog").dialog('open');
			return false;
		});
	});
}

function addLoginListenerExample() {
	$('#review_login_dialog').dialog({
		autoOpen : false,
		modal : true
	});

	var $bookingButton3 = $('#search_deals li:eq(3)').find('.booking_info');
	$bookingButton3.click(function() {
		jQuery("#review_login_dialog").dialog('open');
		return false;
	});
}
