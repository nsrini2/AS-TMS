(function($) {  // $ = jQuery within this block

$(document).ready(function() {

	$('#primary')
		.find('#stats_by_date input.datepicker').setup_start_end_datepickers_for_stats().end()
		.find('#shady_history input.datepicker').setup_start_end_datepickers_for_shady_history().end()
		.find('.assign').setup_assign_award_links().end()
		.find('.copy').confirm_post("Are you sure you want to copy this award?").end()
		.find('.archive').confirm_post("Are you sure you want to archive this award?").end()
		.find('.unarchive').confirm_post("Are you sure want to unarchive this award?").end()
		.find('.toggle_marketing_message').toggle_marketing_message().end()
		.find('.new_marketing_image, .change_marketing_image').setup_marketing_message_links().end()
		.find('.view_recipients').setup_recipients_link().end()
		.find('.user_actions').setup_user_actions().end()
		.find('#user_setup_form').create_screen_name().end();
});


$.fn.extend({

	create_screen_name: function() {
		return this.each(function() {
			$('#profile_last_name').bind('blur', function(event) {
				if ( $('#profile_screen_name').val() == "" )
					$('#profile_screen_name').val( $('#profile_first_name').val() + ' ' + $('#profile_last_name').val() );
			});
		});
	},

	setup_assign_award_links: function() {
		return this.dialog_for_form({ 
			dialogClass: 'assign_award',
			onShow: function($dialog) {
				$dialog.find('#profile_award_name').setup_name_autocomplete({ url: "/profile_awards/auto_complete_for_profile_awards" });
			}
		 });
	},

	setup_marketing_message_links: function() {
		return this.live('click', function(event) {
			var $this = $(this);
			$.ajax({
				url: $this.attr('href'), dataType: 'html', type: 'get', 
				success: function(data) {
					var $dialog = $(data);
					$dialog
						.dialog({ modal: true, dialogClass: 'marketing_message popup form_popup', draggable: false, width: null, height: 'auto', minHeight: 0 })
				}
			});
			return false;
		});
	},

	setup_recipients_link: function() {
		return this.live('click', function() {
			var $this = $(this);
			$this.parents('.details').find('.recipients').toggle();
			return false;
		});
	},
	
	setup_start_end_datepickers_for_shady_history: function() {
		var $this = $(this), $start = $this.filter('.start'), $end = $this.filter('.end');
		return this.setup_start_end_datepickers({
			mandatory: true,
			beforeShow: function(input) {
				return {
					minDate: $(input).is('.end') ? $start.datepicker('getDate') : null,
					maxDate: $(input).is('.start') ? $end.datepicker('getDate') : 'today'
				};
			}
		});
	},

	setup_start_end_datepickers_for_stats: function() {
		var $this = $(this), $start = $this.filter('.start'), $end = $this.filter('.end');
		return this.setup_start_end_datepickers({
			mandatory: true,
			beforeShow: function(input) {
				return {
					minDate: $(input).is('.end') ? $start.datepicker('getDate') : null,
					maxDate: $(input).is('.start') ? $end.datepicker('getDate') : 'today'
				};
			}
		});
	},

	setup_user_actions: function() {
		return this.bind('change', function(event) {
			var $this = $(this), urls = $this.parent().metadata(), val = $this.val();
			switch( val ) {
				case "registration_details":
					window.location.href = urls.registration_details_url;
					break;
				case "edit":
					window.location.href = urls.edit_url;
					break;
				case "delete":
					$.confirmation_dialog({
						title: 'Are you sure you want to delete this user?',
						yes: function() {
							$.ajax({ url: urls.delete_url, type: 'post', data: { '_method': 'delete' },
								success: function(data) { window.location.reload(); }
							});
						}
					});
					break;
				case "reset_password":
					$.confirmation_dialog({
						title: 'Are you sure you want to reset this user\'s password?',
						yes: function() {
							$.ajax({ url: urls.reset_password_url, type: 'post',
								success: function(data) { window.location.reload(); }
							});
						}
					});
					break;
				case "clear_lock":
					$.confirmation_dialog({
						title: 'Are you sure you want to clear the lock on this account?',
						yes: function() {
							$.ajax({ url: urls.clear_lock_url, type: 'post', 
								success: function(data) { window.location.reload(); }
							});
						}
					});
					break;
				case "activate_user":
					$.confirmation_dialog({
						title: 'Are you sure you want to activate this user?',
						yes: function() {
							$.ajax({ url: urls.activate_user_url, type: 'post',
								success: function(data) { window.location.reload(); }
							});
						}
					});
					break;
					case "activate_on_login_user":
  					$.confirmation_dialog({
  						title: 'Are you sure you want to activate this user on login?',
  						yes: function() {
  							$.ajax({ url: urls.activate_on_login_user_url, type: 'post',
  								success: function(data) { window.location.reload(); }
  							});
  						}
  					});
  					break;	
				case "resend_welcome":
					$.confirmation_dialog({
						title: 'Are you sure you want to resend a welcome email to this user?',
						yes: function() {
							$.ajax({ url: urls.resend_welcome_url, type: 'post',
								success: function(data) { window.location.reload(); }
							});
						}
					});
					break;
			}
			$this.val('').blur();
		});
	},

	toggle_marketing_message: function() {
		return this.live('click', function() {
			var $this = $(this).blur(), $img = $this.find('img');
			if ( $img.attr('src').indexOf("icon_active.png") > 0 )
				$img.attr({
					src: "/images/icon_inactive.png",
					title: "Click to activate"
				});
			else
				$img.attr({
					src: "/images/icon_active.png",
					title: "Active message"
				});
			$.ajax({ url: $this.attr('href'), dataType: 'json', type: 'post' });
			return false;
		});
	}

});

})(jQuery);


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