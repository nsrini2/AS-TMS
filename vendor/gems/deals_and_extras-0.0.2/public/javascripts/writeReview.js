$(function() {
    observeEvents();
});

function observeEvents(){
    $('.review_write_submit_button').click(function(e){
        e.preventDefault();
        var form = e.target.parentNode;
        var errors_div = $('.form_errors');
        $.ajax({
            type: 'POST',
            url: form.action,
            data: $(form).serialize(),
            success: function(e){
                if(e.status){
                    $(window).trigger('agentstream:closeModal')
                }else{
                    errors_div.html(e.errors);
                }
            }
        });
    });
}
