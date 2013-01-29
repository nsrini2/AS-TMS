$(function() {
    cloneSearchRows();
    observeSearchEvents();
});

function observeSearchEvents(){
    $('div[class=pagination] a').click(function(e){
        e.preventDefault();
        $(window).trigger('agentstream:filterSearch', [e.target.href]);
    });
    $('.booking_info').click(function(e){
        e.preventDefault();
        var $this = $(this);
        
        $(window).trigger('agentstream:showBooking', [$this.attr('value')]);
    });
    $('#search_deals li').each(function(index) {
        var $viewReviews = $(this).find('.deal_view_reviews');
        $viewReviews.click(function(e){
            e.preventDefault();
            $(window).trigger('agentstream:showReviews', [e.target.value]);
        });
    })
    $('#search_deals li').each(function(index) {
        $(this).find('.deal_write_review').click(function(e){
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
    $('.download_pdf_link').click(function(e){
        e.preventDefault();
        $(window).trigger('agentstream:showPDFdownload', [e.target.parentNode.href]);
    });
}

function cloneSearchRows() {
    initializeSearchDealsAfterRowsAreCloned();
}

function initializeSearchDealsAfterRowsAreCloned() {
    addDetailsButtonListeners();
    addAddToFolderButtonListeners();
    stripeTable();
    //$('#review_dialogs').html("").load("reviewDialogs.html");
}

function addDetailsButtonListeners() {

    $('#search_deals li').each(function(index) {
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

function addAddToFolderButtonListeners() {
    $('#search_deals li').each(function(index) {

        var $addToFolder = $(this).find('.add_remove_folder');

        $addToFolder.click(function(e) {
          $this = $(this);
          $form = $this.parent().parent();
          
          $.post($form.attr('action'), 
                 $form.serialize(),
                 function(data) {
                   if ($this.attr('value') == "Add to Folder") {
                       // $this.attr('value',"Remove from Folder");
                       if(data == "ok") {
                        $form.replaceWith('<div class="folder_login">Added to Folder</div>');
                       }
                       else {
                         $form.replaceWith('<div class="folder_login">Please <a href="/account/login">login</a> to <b>Add to Folder</b></div>');
                       }
                        
                   } else {
                       // Shouldn't happen
                       $this.attr('value',"Add to Folder");
                   }
                 }
          );
          return false;
        });
        
        // $addToFolder.live('ajax:success', function(event, data, status, xhr){  
        //   $this = $(this);
        // 
        //   alert('saved');
        //   if($this.html() == "Add to Folder"){
        //       $this.html("Remove from Folder");
        //   }else{
        //       $this.html("Add to Folder");
        //   }         
        // });
    });
}

function swapDetailsForTarget(srcElement) {

    var $parent = $(srcElement).closest("li.search_deal");

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
    $('#search_deals li:odd').addClass('odd');
    $('#search_deals li:even').addClass('even');
}




// (function($) {  // $ = jQuery within this block
// 
// // Always send the authenticity_token with ajax
// $(document).ajaxSend(function(event, request, settings) {
//  if ( settings.type == 'post' ) {
//    settings.data = (settings.data ? settings.data + "&" : "") + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
//    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//  }
// });
// 
// })(jQuery);