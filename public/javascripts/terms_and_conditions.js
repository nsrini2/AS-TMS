$(document).ready( function() {
  if ($('#terms_and_conditions_overlay').length>0) {
    jQuery.facebox($('#terms_and_conditions_overlay').html());
    $('#facebox').addClass('tac_facebox');
  }
});