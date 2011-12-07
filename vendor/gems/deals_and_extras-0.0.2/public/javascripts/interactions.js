$(function() {
    
    $('#filter').html("loading filter").load("filters");
    $('#sortView').html("loading sortView").load("sorts");
    $('#navigationView').html("loading navigationView").load("navigations");

    $('#contentContainer').html("loading dealsTable");
    filterDealsTable();

    //$('#pageNavigation').html("loading pageNavigation").load("/navigations/page");
    
    observeEvents();
});

var lastPage = 1;

function observeEvents(){
    $(window).bind('agentstream:filterSearch', filterDealsTable);
    $(window).bind('agentstream:updateNumResults', updateNumResults);
    $(window).bind('agentstream:showBooking', showBookingModal);
    $(window).bind('agentstream:showReviews', showReviewsModal);
    $(window).bind('agentstream:showWriteReviews', showWriteReviewsModal);
    $(window).bind('agentstream:closeModal', $.facebox.close);
    $(window).bind('agentstream:loginModal', showLoginModal);
    $(window).bind('agentstream:showPDFdownload', showPDFdownload);

    $(document).ready(function($) {
      $('a[rel*=facebox]').facebox() 
    });
}

function showPDFdownload(e, href){
    $.facebox({
        ajax: '/reports/prepare/' + escape(href).replace(/\//g, "%2F")
    });
}

function showLoginModal(e){
    $.facebox({
        ajax: '/users'
    })
}

function showWriteReviewsModal(e, offer_id, default_state){
    default_state = default_state || '';
    $.facebox({
        ajax: '/offers/' + offer_id + '/reviews/new' + '/' + default_state
    });
}

// show reviews modal
function showReviewsModal(e, offer_id){
    $.facebox({
        ajax: '/offers/' + offer_id + '/reviews'
    });
}

// show the bookings modal window
function showBookingModal(e, offer_id){
    $.facebox({
        ajax: '/offers/' + offer_id + '/book'
    });
}

// load the deals table based on filter criteria
function filterDealsTable(e, url){
    var url;
    var y = parseInt(url);

    if(!url){
        // if a url is not specified try to get to the last page viewed
        url = '/offers?page=' + lastPage;
    }else if(!isNaN(y) && (url == y && url.toString() == y.toString())){
        // check to see if this is just a number and go to that page
        url = '/offers?page=' + url.toString();
    }
    
    // do the call to filter offers
    var get_string = $('#filter_form').serialize() + "&" + $('#sorts_filter').serialize()
    $.get(url, get_string, function(data){
        $('#contentContainer').html(data);
    });
    
    // set the last page to be used during page changes
    lastPage = $.parseQuery(url).page || 1;
}

function paginate_favorites(e, url){
    e.preventDefault();
    alert("paginate_favs");
}

function updateNumResults(e, num){
    $('#filter_header_line1').html(num + ' Results');
}