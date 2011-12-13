$.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});

$(function() {
    
    //$('#filter').html("loading filter").load("/filters");
    //$('#sortView').html("loading sortView").load("/sorts");
    //$('#navigationView').html("loading navigationView").load("/navigations");

    //$('#contentContainer').html("&nbsp;&nbsp;loading dealsTable");
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
        ajax: '/reports/prepare?id=' + escape(href).replace(/\//g, "%2F")
    });
}

function showLoginModal(e){
    $.facebox({
        ajax: '/account/quick_registration'
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

function loadingImage() {
  return "<div class=\"loading\"><img src=\"/images/de/loading.gif\" alt='Loading...'/></div>"
}

// load the deals table based on filter criteria
function filterDealsTable(e, url){
    var url;
    var y = parseInt(url);
    // SSJ 12-11-2011 only limit results to passed id on pageLoad
    // any ajax updates should ignore this param -- there has got to be a better way to do this
    if(url === undefined) {
      var deal_id = $.getUrlVar('deal');
    };
    
    if(!url){
        // if a url is not specified try to get to the last page viewed
        url = '/offers?page=' + lastPage;
    }else if(!isNaN(y) && (url == y && url.toString() == y.toString())){
        // check to see if this is just a number and go to that page
        url = '/offers?page=' + url.toString();
        // if a number is passed, then don't limit results to one id
        deal_id = undefined;
    }
    
    $('#contentContainer').html(loadingImage());
    
    // do the call to filter offers
    if(deal_id === undefined) {
      var get_string = $('#filter_form').serialize() + "&" + $('#sorts_filter').serialize()
    } else {
      var get_string = "deal=" + deal_id ;
    };
    
    
    $.get(url, get_string, function(data){
        $('#contentContainer').html(data);
        
        // fill in the results count
        results_count = $('#pageNavigation b:last').html().replace("all&nbsp;","");
        $('#filter_header_line1').html(results_count + " Results");
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



$(document).ready( function() {
  if ($('#de_visitor_overlay').length>0) {
    jQuery.facebox($('#de_visitor_overlay').html());
   // $('#de_visitor_overlay').facebox();
  }
  
  $('#pdf_submit').live('click', function() {
    var $this = $(this);
    $this.attr('disabled', 'disabled');
    setTimeout(function() { $this.attr('disabled', '') },30000);
  })
});