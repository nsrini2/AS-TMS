$(function() {
    observeEvents();
});

function observeEvents(){
    $('.review_write_submit_button').click(function(e){
        e.preventDefault();
        var $form = $(e.target).parents('form:first');  
        var errors_div = $('.form_errors');
        $.ajax({
            type: 'POST',
            url: $form.attr('action'),
            data: $form.serialize(),
            success: function(e){
                if(e.status){
                    if(e.temp_user) {
                      $(window).trigger('agentstream:loginModal');
                    }
                    else {
                      $(window).trigger('agentstream:closeModal');
                      seal_container = 'offer_' + e.offer_id + '_seal_container';
                      seal_container_class = 'seal_' + e.percentage.toString();

                      $seal_container = $('#' + seal_container)
                      $seal_container.removeClass('first_seal'); // If it's there
                      $seal_container.addClass(seal_container_class);
                      
                      $seal_container.parent().find('.deal_thumbs img').hide();
                    }
                }else{
                    errors_div.html(e.errors);
                }
            }
        });
    });
}
