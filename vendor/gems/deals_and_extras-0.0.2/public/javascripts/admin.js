$(function(){
    jQuery(document).ready(function($) {
      $('a[rel*=facebox]').facebox() 
    })
    $("#update_latlong").click(update_latlong);
    $("#add_offer_type").click(add_offer_type);
});

function add_offer_type(e){
    e.preventDefault();
}

function update_latlong(e){
    e.preventDefault();
    $('#latlong').html("<img style='display: inline;' src='/images/loading.gif'>");
    $.ajax({
        type: 'POST',
        url: '/admin/offers/' + $("#offer_id")[0].value + '/update_latlong',
        success: function(e){ $('#latlong')[0].innerHTML = e; }
    })
}