$(function() {
    observeEvents();
});

function observeEvents(){
    
    $('div[class=pagination] a').click(function(e){
        e.preventDefault();
        var review_view_dialog = $('#review_view_dialog');
        $.ajax({
            type: 'GET',
            url: e.target.href,
            success: function(e){
                review_view_dialog.html(e);
            }
        });
    });

}
