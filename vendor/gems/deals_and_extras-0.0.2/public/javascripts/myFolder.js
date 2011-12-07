$(function() {
	cloneMyFolderDeal();
});

function cloneMyFolderDeal() {
    addDetailsButtonListenersNow();
    stripeTable();
    editDealTitle();
    observeEvents();
    hideElements();
}

function observeEvents(){
    $('#download_pdf_link').click(function(e){
        e.preventDefault();
        $(window).trigger('agentstream:showPDFdownload', [e.target.href]);
    });
    $('.booking_info').click(function(e){
        e.preventDefault();
        $(window).trigger('agentstream:showBooking', [e.target.value]);
    });
    $('.remove_from_favorites').click(function(e){
        $(e.target.parentNode.parentNode).hide('fast', function(){
            $(this).remove();
            stripeTable();
        });
        $.post(
            '/favorites/' + e.target.value,
            { '_method': 'delete' }
        );
    });
    $('#myFolder li').each(function(index) {
        var $viewReviews = $(this).find('.deal_view_reviews');
        $viewReviews.click(function(e){
            e.preventDefault();
            $(window).trigger('agentstream:showReviews', [e.target.value]);
        });
    })
    $('#myFolder li').each(function(index) {
        var $viewReviews = $(this).find('.deal_write_review');
        $viewReviews.click(function(e){
            e.preventDefault();
            $(window).trigger('agentstream:showWriteReviews', [e.target.value]);
        });
        $(this).find('img.deal_thumbs_up').click(function(e){
            e.preventDefault();
            $(window).trigger('agentstream:showWriteReviews', [e.target.alt, 'up']);
        });
        $(this).find('img.deal_thumbs_down').click(function(e){
            e.preventDefault();
            $(window).trigger('agentstream:showWriteReviews', [e.target.alt, 'down']);
        });
    });
    $('div[class=pagination] a').click(function(e){
        e.preventDefault();
        $(window).trigger('agentstream:filterSearch', [e.target.href]);
    });
}

function addDetailsButtonListenersNow() {

	$('#myFolder li').each(function(index) {
		var $details = $(this).find('.details_style');
		$details.hide();

		var $showMore = $(this).find('button.show_more_style');
		$showMore.click(function(e) {
			swapDetailsForTarget(e.target || e.srcElement);
		});

		var $title = $(this).find('.deal_title');
		$title.click(function(e) {
			swapDetailsForTarget(e.target || e.srcElement);
		});
	});
}

function hideElements() {
	$('#myFolder li').each(function(index) {
		var $details = $(this).find('.details_style');
		var $editDeal = $(this).find('.my_folder_edit_deal');
		var $dealTitleEditor = $(this).find('.my_folder_title_editor');
		var $saveChanges = $(this).find('.my_folder_save_changes');
		var $cancelChanges = $(this).find('.my_folder_cancel_changes');

		$details.hide();
		$editDeal.hide();
		$dealTitleEditor.hide();
		$saveChanges.hide();
		$cancelChanges.hide();
	});
}

function swapDetailsForTarget(srcElement) {

	var $parent = $(srcElement).closest("li.my_folder_deal");

	var $details = $parent.find('div.details_style');
	var $showMore = $parent.find('button.show_more_style');

	if ($details.is(":visible")) {
		$details.hide();
		$showMore.html("+Show Details");
	} else {
		$details.show();
		$showMore.html("-Hide Details");
	}
}

function stripeTable() {
	$('#dealsTable li:odd').removeClass('odd').removeClass('even').addClass('odd');
	$('#dealsTable li:even').removeClass('odd').removeClass('even').addClass('even');
}

function editDealTitle() {
	$('#myFolder li').each(function(index) {
		var $dealTitle = $(this).find('.deal_title');
		var $editDeal = $(this).find('.my_folder_edit_deal');
		var $titleEditor = $(this).find('.my_folder_title_editor');
		var $saveChanges = $(this).find('.my_folder_save_changes');
		var $cancelChanges = $(this).find('.my_folder_cancel_changes');

		$editDeal.click(function() {
			$dealTitle.hide();
			$titleEditor.show();
			$saveChanges.show();
			$cancelChanges.show();
		});

		// should work on hovering over the image as well
		$dealTitle.hover(function() {
			var currentTitle = $dealTitle.html();
			$titleEditor.attr("value", currentTitle);

			$editDeal.show();

		});

        $saveChanges.click(function(e) {
            var newTitle = $titleEditor.attr("value");
            $dealTitle.html(newTitle);
            $dealTitle.show();
            $titleEditor.hide();
            $saveChanges.hide();
            $cancelChanges.hide();
            $editDeal.hide();
            $.post(
                '/favorites/' + e.target.title,
                {
                    '_method' : 'put',
                    'custom_title' : $dealTitle.html()
                }
            );
        });

		$cancelChanges.click(function() {
			$dealTitle.show();
			$titleEditor.hide();
			$saveChanges.hide();
			$cancelChanges.hide();
			$editDeal.hide();
		});
	});
}
