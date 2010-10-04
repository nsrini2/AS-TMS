(function($) {  // $ = jQuery within this block


$(document).ready(function() {
	$('#primary')
		// plugins/widgets/utilities
		.find('.inline_editable').setup_inline_editor().end()
		.find('.tooltip').setup_tooltips().end()
		.find(':input[maxlength]').setup_character_counter().end()
		.find('#question_question, #answer_answer, textarea#group_description').expandable().end()
		.find('#welcome_note_name').setup_name_autocomplete({ url: '/admin/auto_complete_for_welcome_note' }).end()
		.find('#hub_widgets').sortable_hub_widgets().end();
	$('#primary')
		// Ajaxified links
		.find('.watch').setup_watch_links().end()
		.find('.follow').setup_follow_links().end()
		.find('div.rate ul').setup_rating().end()
		.find('.request_invite').request_invite().end()
		.find('.accept').accept_invite().end()
		.find('.decline').decline_invite().end()
		.find('#profile .make_default').make_default_photo().end()
		.find('.select_moderator_option').setup_select_moderator_option_links().end()
		.find('.cbtoggle').toggle_checkboxes().end()
		.find('.toggle').toggle_containers().end()
		.find('.booking_privacy').privacy_toggle().end()
		.find('#site_registration_field_has_options').toggle_site_registration_field_options().end()
		// Reports
		.find('.accordion').setup_accordion().end()
		.find('.report_draggable').report_draggable_setup().end()
		.find('.report_droppable').report_droppable_setup().end()
		.find('#report_save').report_save().end()
		.find('#report_klass_select').report_update_klass().end()
		// Status
		.find('#widget_status').setup_status_update_from_widget().end()
		.find('#profile_status_form').setup_status_update_from_profile().end()
		// Dialogs/Modals
		.find('.delete').confirm_delete().end()
		.find('.delete_watch').confirm_delete_watch().end()
		.find('.join_group').confirm_join().end()
		.find('.invite_all').confirm_post("Are you sure you want to Resend All Invitations?").end()
		.find('.remove').confirm_post("Are you sure you want to remove this?").end()
		.find('.remove_member').confirm_post("Are you sure you want to remove this member?").end()
		.find('.quit_group').confirm_post("Are you sure you want to quit this group?").end()
		.find('#mass_mailer').confirm_send_to_all().end()
		.find('#ownership_transfer .assign_link a').confirm_post("Are you sure you want to assign this person as the owner of the group?").end()
		.find('#moderator_settings .assign_link')
			.find('a.assign').confirm_post("Are you sure you want to assign this person as a moderator of the group?").end()
			.find('a.unassign').confirm_post("Are you sure you want to unassign this person as a moderator of the group?").end()
		.end() 
		.find('.progress').setup_progressbar().end()
		.find('form.disable_buttons_on_submit').disable_on_submit().end()
		.find('.completion_info').dialog_for_completion_info().end()
		.find('.karma_info').dialog_for_karma_info().end()
		.find('.encoding_info').dialog_for_encoding_info().end()
		.find('.invite').dialog_for_group_invite().end()
		.find('.shady').dialog_for_shady().end()
		.find('.view_all_awards').dialog_for_awards().end()
		.find('.create_group').dialog_for_create_group().end()
		.find('.edit_comment').dialog_for_edit_comment().end()
		.find('.group_post_item')
					.find('.reply').dialog_for_group_talk_reply().end()
				.end()
				.find('.question')
					.find('.close').confirm_close_question().end()
					.find('.edit').dialog_for_question_edit().end()
					.find('.refer').dialog_for_question_refer().end()
				.end()
				.find('.answer')
					.find('.best').confirm_best_answer().end()
					.find('.edit').dialog_for_answer_edit().end()
					.find('.new_reply').dialog_for_answer_reply().end()
					.find('.edit_reply').dialog_for_answer_reply_edit().end()
				.end()
				.find('#profile')
					.find('.change_photo').dialog_for_photo_upload().end()
					.find('.new_photo').dialog_for_photo_upload().end()
				.end()
				// Datepickers
				.find('#ask_a_question dt.closing_date').setup_question_datepicker().end()
				.find('#app_6 dt.closing_date').setup_question_datepicker().end()
				.find('#object_start_date, #object_end_date').setup_start_end_datepickers_for_announcement().end()
				.find('#group_announcement_start_date, #group_announcement_end_date').setup_start_end_datepickers_for_announcement().end()
				// Misc
				.find('.answer .vote').setup_vote_answer_links().end()
				.find('#members_images').setup_member_wall().end()
				.find('#more_matched_questions').load_more_matched_questions().end()
				.find('input')
			.filter('.keywords').submit_on_enter_keydown().end()
			.filter('.blog_tags').setup_blog_tags_autocomplete().end()
		.end()
		.find('#site_logo')
			.find('.change_photo').dialog_for_photo_upload().end()
		.end()
		.find('#site_favicon')
			.find('.change_photo').dialog_for_photo_upload().end()
		.end()
		.find('textarea.fckeditor').setup_ckeditor().end()
		.find('#flagged a.view_log').open_in_new_window().end()
		// Resize multiple hub iframes
		// .find('#iframe_app_*').adjust_iframe_height().end()
		.find("iframe:regex(id, iframe_app_.*)").adjust_iframe_height().end()
		.find('#group_preferences').setup_group_email_settings().end()
		.find('#group').prepare_photo_upload_modal().end()
		.find('#new_group_post').setup_group_talk_form().end()
		.find('#stream').refresh_event_stream().end()
		.find('div.flash').setup_flash().end()
		.find('div.profile_results').equal_heights_for('div.profile').end()
		.find('#answer_form').setup_answer_form().end()
		.find('#filter_form').setup_filter_form().end()
		.find('#profile .alternate_photos a').setup_alternate_photos().end();


	$('#flash_notice, #flash_error').setup_notices();

	$('.ui-dialog .close').live('click', function(event) {
		$(this).parents('.popup_content').dialog('destroy').remove();
		return false;
	});
});

var stream_interval;

$.fn.extend({

	toggle_checkboxes: function() {
		return this.live('click', function(event) {
			var $this = $(this);
			jQuery.each($("input[name^='" + "sendcbToggle" + "']"), function() {
				($this.attr('checked') == true) ? 
				$(this).attr('checked', 'checked') : $(this).removeAttr('checked');  				
			});
		});
	},
	
	disable_on_submit: function() {
		return this.bind('submit', function(event) {
			$("input[type=submit]").attr("disabled","true");  				
		});
	},
	
	// Ajax post to toggle the privacy of a booking
	privacy_toggle: function() {
		return this.bind('click', function(event) {
			var $this = $(this);
			$.ajax({ url: '/travels/' + $this.attr('value') + '/toggle_privacy', dataType: 'json', type: 'post',
				success: function(data) {
					if ( data["errors"] ) {
						for ( var i=0; i<data["errors"].length; i++ ) {
							$('#flash_error ul').append('<li>' + data["errors"][i] + '</li>');
							$('#flash_error').setup_notices();
						}
					} else {
						text = data["new_public"] == true ? "This trip is now Shared." : "This trip no longer shared."
						$('#flash_notice ul').append('<li>' + text +'</li>');
						$('#flash_notice').setup_notices();
					} 
				}
			});
		});
	},

	// Takes links with ids like this: a_b_c_link
	// Toggles all elements with ids like: a_b_c.*
	// Would do: a_b_c_1 and a_b_c_2
	toggle_containers: function() {
		return this.live('click', function(event) {
			var $this = $(this);
			var this_id = $this.attr('id');
			var this_id_base_array = this_id.split("_")
			this_id_base_array.pop();
			var this_id_base = this_id_base_array.join("_");
			jQuery.each($("div[id^='" + this_id_base + "']"), function() {
				$(this).toggle();
			});
		});
	},
	
	toggle_site_registration_field_options: function() {
		return this.bind('click', function(event) {
			$('#site_registration_field_options_container').toggle();
			$('#site_registration_field_options').empty();
		});
	},
	
	// Status
	setup_status_update_from_widget: function() {
		return this.bind('submit', function() {
	    $this = $(this);

	    var status_body = $('#status_body').val();

	    // Check that the status body is at least 1 characters
	    if(status_body.length < 1) {
	      alert('Your update must be at least 1 character long.\n\nIt is currently ' + status_body.length + ' characters.');
	      return false;
	    }

	    // Check that the status body is under 140 characters
	    if(status_body.length > 140) {
	      alert('Your update must be less than 140 characters.\n\nIt is currently ' + status_body.length + ' characters.');
	      return false;
	    }

	    // Actually post it
	    $.ajax({ url: $this.attr('action'), dataType: 'html', type: 'post', data: $this.serialize(),
				beforeSend: function() {
					$this.find('input.button').each(function() {
						$input = $(this);
						$input.attr('value', 'Updating...');
						$input.attr('disabled', 'disabled');
					});
				},
				success: function(data) {
					if ( data == "Not Saved" ) {
						$('#flash_error ul').append('<li>' + 'There was an error while updating your status.' + '</li>');
						$('#flash_error').setup_notices();
					} else {
	          var widget_status_events = $('#widget_status_events');
	          var status_div = data;

	          widget_status_events.prepend(status_div);

	          $('#status_body').val("");
					}
				},
				complete: function() {
					$this.find('input.button').each(function() {
						$input = $(this);
						$input.attr('value', 'Update');
						$input.removeAttr('disabled');
					});
				}
			});

	    return false;
	  });
	},
	
	// TODO: DRY this up....
	setup_status_update_from_profile: function() {
		return this.bind('submit', function() {
	    $this = $(this);

	    var status_body = $('#status_body').val();

	    // Check that the status body is at least 1 characters
	    if(status_body.length < 1) {
	      alert('Your update must be at least 1 character long.\n\nIt is currently ' + status_body.length + ' characters.');
	      return false;
	    }

	    // Check that the status body is under 140 characters
	    if(status_body.length > 140) {
	      alert('Your update must be less than 140 characters.\n\nIt is currently ' + status_body.length + ' characters.');
	      return false;
	    }

	    // Actually post it
	    $.ajax({ url: $this.attr('action'), dataType: 'html', type: 'post', data: $this.serialize(),
				beforeSend: function() {
					$this.find('input.button').each(function() {
						$input = $(this);
						$input.attr('value', 'Updating...');
						$input.attr('disabled', 'disabled');
					});
				},
				success: function(data) {
					if ( data == "Not Saved" ) {
						$('#flash_error ul').append('<li>' + 'There was an error while updating your status.' + '</li>');
						$('#flash_error').setup_notices();
					} else {
	          var profile_status_events = $('#profile_status_events');
	          var status_div = data;

	          profile_status_events.prepend(status_div);

	          $('#status_body').val("");
					} 
				},
				complete: function() {
					$this.find('input.button').each(function() {
						$input = $(this);
						$input.attr('value', 'Update');
						$input.removeAttr('disabled');
					});
				}
			});

	    return false;
	  });
	},

	// Drag and Drop
	report_draggable_setup: function() {
		return this.each(function() {
			var $this = $(this);
			$this.draggable({
				revert: true,
				ghosting: true
			});
		});
	},

	report_draggable_in: function(id) {
		var $this = $(this);
		if(id.match(/^attributes/) != null) {
			$this.report_attribute_in(id);
		}
		else if(id.match(/^associations/) != null) {
			$this.report_association_in(id);
		}
	},

	report_association_in: function(association_id) {
		var $this = $(this); // The droppable
		
		var ui_id = association_id;		
		var ui_li_text = ui_id.slice(12, ui_id.length).replace(/\]\[/g," ").replace(/(\[|\])/g,"").replace(/_/g, " ").titleCase();
		var ui_li_id = ui_id.replace(/\[/g,"_").replace(/\]/g,"") + "_active";
		var ui_field_id = ui_li_id + "_field";
		var ui_field_name = "associations" + ui_id.slice(12, ui_id.length);
		
		var out_link = "  <a href=\"#\">x</a>"
		
		// Remove the over class
		$this.removeClass('report_droppable_over');
		
		// Add content to ul
		$this.find('ul#active_fields').append("<li id=\"" + ui_li_id + "\" class=\"draggable\">" + ui_li_text + out_link + "</li>");

		// Add 'out' link
		$this.find('ul#active_fields li#' + ui_li_id + " a").bind('click', function(event) {
			$this.report_association_out(association_id);
		});
		
		// Add hidden field
		$this.append("<input type=\"hidden\" name=\"" + ui_field_name + "\" id=\"" + ui_field_id + "\">");
		
		// Refresh the report preview
		$this.refresh_report_preview();		
	},

	report_attribute_in: function(attribute_id) {
		var $this = $(this); // The droppable
		
		var ui_id = attribute_id;
		var ui_li_text = ui_id.slice(11, ui_id.length).titleCase();
		var ui_li_id = ui_id + "_active";
		var ui_field_id = ui_li_id + "_field";
		var ui_field_name = "attributes[" + ui_id.slice(11, ui_id.length) + "]";
		
		var out_link = "  <a href=\"#\">x</a>"
		
		// Remove the over class
		$this.removeClass('report_droppable_over');
		
		// Add content to ul
		$this.find('ul#active_fields').append("<li id=\"" + ui_li_id + "\" class=\"draggable\">" + ui_li_text + out_link + "</li>");

		// Add 'out' link
		$this.find('ul#active_fields li#' + ui_li_id + " a").bind('click', function(event) {
			$this.report_attribute_out(attribute_id);
		});
		
		// Add hidden field
		$this.append("<input type=\"hidden\" name=\"" + ui_field_name + "\" id=\"" + ui_field_id + "\">");
		
		// Refresh the report preview
		$this.refresh_report_preview();
	},

	refresh_report_preview: function() {
		var reports_form = $('#reports_form');
		var report_preview = $('div#report_preview'); 
		
		$.ajax({ url: reports_form.attr('action'), dataType: 'html', type: 'post', data: reports_form.serialize(),
							beforeSend: function(request) {
								var report_preview_table = report_preview.find('table');
								report_preview_table.replaceWith("<table>Updating Preview...</table>");
							},
		 					success: function(data) {
								var report_preview_table = report_preview.find('table');
								report_preview_table.replaceWith(data);
							}
		});
	},
	
	report_update_klass: function() {
		return this.each(function() {
			var $this = $(this);
			$this.bind('change', function() {
				$.ajax({ url: '/custom_reports/form_details?klass=' + $this.val(), dataType: 'html', type: 'get',
				 					success: function(data) {
										// Get the data
										var details_container = $('#form_details_container');
										details_container.replaceWith(data);

										var details_container = $('#form_details_container');

										// Add the accordion to newly loaded elements
										details_container.find('.accordion').setup_accordion();

										// Do the drag/drop magic on the newly loaded elements
										details_container.find('.report_draggable').report_draggable_setup();
										details_container.find('.report_droppable').report_droppable_setup();
										
									},
									// MM2: I would rather this be in success but IE7 doesn't like it there
									complete: function() {
										// Ensure the save button is bound
										var report_save = $('#report_save');
										report_save.report_save();
									}
				});
			});

		});
	},
	
	//Accordion
	setup_accordion: function() {
		return this.each(function() {
			var $this = $(this);
			$this.accordion({ active:false, autoHeight:false, collapsible:true });
		});
	},

// Not needed anymore	
/*	populate_report_preview: function() {
		return this.each(function() {
			var report_preview = $('div#report_preview'); 

			$.ajax({ url: "/reports", dataType: 'html', type: 'get', data: $('div#custom_report_form').text(),
								beforeSend: function(request) {
									var report_preview_table = report_preview.find('table');
									report_preview_table.replaceWith("<table><tr><td>Updating Preview...</td></tr></table>");
								},
			 					success: function(data) {
									var report_preview_table = report_preview.find('table');
									report_preview_table.replaceWith(data);
								}
			});			
		});
	},*/

	report_attribute_out: function(attribute_id) {
		var $this = $(this); // droppable
		
		var ui_id = attribute_id;
		var ui_li_id = ui_id + "_active";
		var ui_field_id = ui_li_id + "_field";
		var ui_field_name = "attributes[" + ui_id.slice(11, ui_id.length) + "]";
		
		// Remove content from ul
		$this.find('ul#active_fields li#' + ui_li_id).remove();//("<li id=\"" + ui_li_id + "\" class=\"draggable\">" + ui_id + out_link + "</li>");
		
		// Remove hidden field
		$this.find("input#" + ui_field_id).remove();
		
		// Refresh the report preview
		$this.refresh_report_preview();
		
		//return(false);
	},
	
	report_association_out: function(association_id) {
		var $this = $(this); // The droppable
		
		var ui_id = association_id;		
		var ui_li_id = ui_id.replace(/\[/g,"_").replace(/\]/g,"") + "_active";
		var ui_field_id = ui_li_id + "_field";
		var ui_field_name = "associations" + ui_id.slice(12, ui_id.length);
		
		// Remove content from ul
		$this.find('ul#active_fields li#' + ui_li_id).remove();//("<li id=\"" + ui_li_id + "\" class=\"draggable\">" + ui_id + out_link + "</li>");
		
		// Remove hidden field
		$this.find("input#" + ui_field_id).remove();
		
		// Refresh the report preview
		$this.refresh_report_preview();
		
		//return(false);
	},
	
	report_droppable_setup: function() {
		return this.each(function() {
			var $this = $(this);

			jQuery.each(current_attributes, function(idx, attr_name) {
				$this.report_attribute_in("attributes_" + attr_name);
			});
			
			jQuery.each(current_associations, function(idx, assoc_array) {
				assoc_name = assoc_array[0];
				assoc_attrs = assoc_array[1];
				jQuery.each(assoc_attrs, function(idx2, assoc_attr) {
					$this.report_association_in("associations[" + assoc_name + "][" + assoc_attr + "]");					
				});

			});
			
			$this.droppable({
				drop: function(event, ui) {
					$this.report_draggable_in(ui.draggable.attr('id'));
				},
				out: function() { $this.removeClass('report_droppable_over'); },
				over: function() { $this.addClass('report_droppable_over'); }
			});
		});
	},
	
	report_save: function() {
		// MM2: This would actually make a better 'live' than 'bind' but ie7 seems to not like that...
		return this.bind('click', function(event) {			
			var $this = $(this);

			var this_href = $this.attr('href');
			var this_href_array = this_href.split("/");
			var this_href_path = this_href_array[this_href_array.length-1];
			
			var this_method = (this_href_path == "custom_reports" ? "post" : "put");
			var new_report = (this_href_path == "custom_reports");
			
			var reports_form = $('#reports_form');			
			var report_data =  reports_form.serialize() + "&custom_report[form]=" + encodeURIComponent(reports_form.serialize());

			if(new_report) {
				var name = prompt("Report Name:");
				if(name && name != "") {
					report_data = report_data + "&custom_report[name]=" + name;
				}
				else {
					alert("You must name this report in order to save it.");
					return(false);
				}
			}
			
			$.ajax({ url: this_href, dataType: 'html', type: this_method, data: report_data,
								error: function() {
									alert('There was an error saving this report.');
								},
			 					success: function(data) {
									window.location = '/custom_reports';
								}
			});

			return(false);
		});
	},



	adjust_iframe_height: function() {
		return this.each(function() {
			var $iframe = $(this);
			function adjust_iframe_height() {
				var doc = $iframe[0] && frames[$iframe[0].name].document;
				if ( doc )
					$iframe.height( doc.height || Math.max( (doc.body && doc.body["scrollHeight"] || 0), (doc.documentElement && doc.documentElement["scrollHeight"] || 0) ) );
			};
			setInterval(adjust_iframe_height, 2000);
		});
	},

	confirm_best_answer: function() {
		return this.live('click', function(event) {
			var $this = $(this);
			$.confirmation_dialog({
				title: "Are you sure you want to mark this answer best?", 
				yes: function() {
					window.location = $this.attr('href');
				}
			});
			return false;
		});
	},

	confirm_close_question: function() {
		return this.live('click', function(event) {
			var $this = $(this), $question = $this.parents('.question:first'),
				months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
			$.confirmation_dialog({
				title: "Are you sure you want to close this question?",
				body: "<p>Closing a question prevents other members from answering it.</p>",
				yes: function() {
					$.ajax({ url: $this.attr('href'), type: 'post', data: { '_method': 'put' }, dataType: 'json', 
						success: function(data) {
							$('.popup.confirmation').dialog('destroy').remove();
							$question.fadeTo('normal', 0, function() {
								$question
									.find('div.action_buttons')
										.html('<div class="closed">Closed to new answers</div>')
									.end()
									.find('span.closing_date')
										.html('Closed On <span id="open_until_818">' + (months[new Date().getMonth()]) + ' ' + (new Date().getDate()) + ', ' + (new Date().getFullYear()) + '</span>')
									.end()
									.fadeTo('normal', 1);
							});
						} 
					});
				}
			});
			return false;
		});
	},

	confirm_delete: function() {
		return this.live('click', function() {
			var $this = $(this);
			$.confirmation_dialog({
				title: 'Are you sure you want to delete it?',
				yes: function() {
					$.ajax({ url: $this.attr('href'), type: 'post', data: { '_method': 'delete' }, dataType: 'json', 
						success: function(data) {
							if ( data["redirect"] ) {
								window.location = data["redirect"];
							} else
								window.location.reload();
						},
						error: function() {
							window.location.reload();
						}
					});
				}
			});
			return false;
		});
	},

	confirm_delete_watch: function() {
		var $url = window.location.pathname == this.attr('href') ? $('#tabs li.selected a').attr('href') : window.location;
		return this.confirm_delete_and_redirect_to($url);
	},

	confirm_delete_and_redirect_to: function(url) {
		return this.live('click', function() {
			var $this = $(this);
			$.confirmation_dialog({
				title: 'Are you sure you want to delete it?',
				yes: function() {
					$.ajax({ url: $this.attr('href'), type: 'post', data: { '_method': 'delete' }, success: function() { window.location = url; } });
				}
			});
			return false;
		});
	},

	confirm_join: function() {
		return this.live('click', function() {
			var $this = $(this);
			$.confirmation_dialog({
				title: "Are you sure you want to join this group?",
				yes: function() {
					$.ajax({ url: $this.attr('href'), type: 'post', dataType: 'json',
						success: function(data) {
							if ( data["errors"] ) {
								$('.popup.confirmation').dialog('destroy').remove();
								for ( var i=0; i<data["errors"].length; i++ ) {
									$('#flash_error ul').append('<li>' + data["errors"][i] + '</li>');
									$('#flash_error').setup_notices();
								}
							} else 
								window.location.reload();
						}
					});
				}
			});
			return false;
		});
	},

	confirm_post: function(title) {
		return this.live('click', function() {
			var $this = $(this);
			$.confirmation_dialog({
				title: title,
				yes: function() {
					$.ajax({ url: $this.attr('href'), type: 'post',
						success: function(data) { window.location.reload(); }
					});
				}
			});
			return false;
		});
	},
	
	

	confirm_send_to_all: function() {
		return this.find('input.confirm')
			.bind('click', function(event) {
				var $form = $(this).parents('form:first');
				$.confirmation_dialog({
					title: "Are you sure you want to send this to all members?",
					yes: function() {
						$form.submit();
						}
				});
				return false;
			})
		.end();
	},

	dialog_for_answer_edit: function() {
		return this.dialog_for_form({ dialogClass: 'edit_answer' });
	},

	dialog_for_answer_reply: function() {
		return this.dialog_for_form({ dialogClass: 'reply_answer' });
	},

	dialog_for_answer_reply_edit: function() {
		return this.dialog_for_form({ dialogClass: 'edit_reply' });
	},

	dialog_for_awards: function() {
		return this.dialog_for_form({ 
			dialogClass: 'awards',
			onShow: function($dialog) {
				$dialog.find('.make_default').confirm_post("Are you sure you want to make this the default?").end()
				.find('.hide_this_award').confirm_post("Are you sure you want to hide this award from public view?").end()
				.find('.make_visible_to_others').confirm_post("Are you sure you want to make this award visible to others?").end();
			}
		});
	},

	dialog_for_create_group: function() {
		return this.dialog_for_form({ dialogClass: 'create_group' });
	},

	dialog_for_edit_comment: function() {
		return this.dialog_for_form({ dialogClass: 'edit_comment_popup' });
	},

	dialog_for_group_invite: function() {
		return this.dialog_for_form({ 
			dialogClass: 'group_invite',
			onShow: function($dialog) {
				$dialog.find('#invitation_profile_name').setup_name_autocomplete({ url: '/group_invitations/auto_complete_for_group_invitation_profile' });
			},
			success: function($dialog, data) {
				$('#flash_notice ul').append('<li>Invitation successfully sent</li>');
				$('#flash_notice').setup_notices();
				$dialog.dialog('destroy').remove();
			}
		});
	},

	dialog_for_group_talk_reply: function() {
		return this.dialog_for_form({ dialogClass: 'reply_talk' });
	},

	dialog_for_form: function(options) {
		options = $.extend({
			dialogClass: '', onShow: function() {  },
			success: function() { window.location.reload();  }
		}, options);
		return this.live('click', function(event) {
			var $this = $(this);
			$.ajax({
				url: $this.attr('href'), dataType: 'html', type: 'get',
				success: function(data) {
					var $dialog = $(data); 
					$dialog
						.dialog({ modal: true, bgiframe: true, dialogClass: 'popup form_popup ' + options.dialogClass, draggable: false, width: null, height: 'auto', minHeight: 0 })  //.find(':input:not(:hidden):first').focus().end() // breaks auto completer
						.find('form').bind('submit', function(event) {
							var $form = $(this);
							$.ajax({
								url: $form.attr('action'), type: 'post', data: $form.serialize(), dataType: 'json',
								success: function(data) {
									if ( data["errors"] ) {
										$form.find('textarea, input').attr('disabled', false);
										for ( var i=0; i<data["errors"].length; i++ ) {
											$('#flash_error ul').append('<li>' + data["errors"][i] + '</li>');
											$('#flash_error').setup_notices();
										}
									} else
										options.success.call($this[0], $dialog, data);								
								}
							}); 								
							$form.find('textarea, input').attr('disabled', true);
							return false;
						});
					 options.onShow.call($this[0], $dialog);
				}
			});
			return false;
		});
	},

	dialog_for_karma_info: function() {
		return this.dialog_for_form({ dialogClass: 'karma_info'});
	},
	
	dialog_for_completion_info: function() {
		return this.dialog_for_form({ dialogClass: 'completion_info'});
	},
	
	dialog_for_encoding_info: function() {
		return this.dialog_for_form({
			dialogClass: 'encoding_info'
		});
	},

	dialog_for_photo_upload: function() {
		return this.live('click', function(event) {
			var $this = $(this);
			$.ajax({
				url: $this.attr('href'), dataType: 'html', type: 'get', 
				success: function(data) {
					var $dialog = $(data);
					$dialog
						.dialog({ modal: true, bgiframe: true, dialogClass: 'photo_upload popup form_popup', draggable: false, width: null, height: 'auto', minHeight: 0 })
						.find('form').bind('submit', function(event) {
							$(this).find('input.button:not(.close)').attr('disabled', true);
						});
				}
			});
			return false;
		});
	},

	dialog_for_question_edit: function() {
		return this.dialog_for_form({
			dialogClass: 'edit_question',
			onShow: function($dialog) {
				$dialog.find('dt.closing_date').setup_question_datepicker();
			}
		});
	},

	dialog_for_question_refer: function() {
		return this.dialog_for_form({
			dialogClass: 'refer_question',
			success: function($dialog, data) {
				$('#flash_notice ul').append('<li>Successfully referred question to ' + data['question_referral']['referred_to_name'] + '</li>');
				$('#flash_notice').setup_notices();
				$dialog.dialog('destroy').remove();
			},
			onShow: function($dialog) {
				$dialog.find('#question_referral_name').setup_name_autocomplete({ url: "/question_referrals/auto_complete_for_referral" });
			}
		});
	},

	dialog_for_shady: function() {
		return this.find('a').dialog_for_form({
			dialogClass: 'shady',
			success: function($dialog) {
				var $span = $(this).parent();
				$dialog.dialog('destroy').remove();
				$span.fadeTo('fast', 0, function() {
					$span.removeClass('shady').addClass('clicked').html('reported as shady').fadeTo('fast', 1);
				});
				
			}
		}).end();
	},

	equal_heights_for: function(selector) {
		var prop = ($.support.minHeight ? 'minHeight' : 'height');
		return this.each(function(){
			$(selector, this).each_slice(2, function() {
				var currentTallest = 0;
				$(this).each(function() {
					var currentHeight = $(this).height();
					if ( currentHeight > currentTallest ) currentTallest = currentHeight;
				}).css(prop, currentTallest); 
			});
		});
	},

	has: function(selector) {
		var $this = this;
		return $this.find(selector).length > 0
	},

	load_more_matched_questions: function() {
		return this.bind('click', function(event) {
			var $this = $(this), $div = $('#more_questions');
			$.ajax({
				url: $this.attr('href'), dataType: 'html', type: 'get', data: { "_method": "put" },
				success: function(data) {
					$div.html(data).stop().fadeTo('normal', 1);
				}
			});
			return false;
		});
	},

	make_default_photo: function() {
		return this.live('click', function(event) {
			var $this = $(this);
			$.ajax({
				url: $this.attr('href'), dataType: 'html', type: 'post', data: { "_method": "put" },
				success: function(data) { $('#photos').html(data); }
			});
			return false;
		});
	},

	open_in_new_window: function() {
		return this.bind('click', function(event) {
			return !window.open(this.href, '_audit', 'resizable=1,scrollbars=1,width=700,height=500');
		});
	},

	prepare_photo_upload_modal: function() {
		$('#upload_gallery_photo').hide().end()
		return $('.title_action_link').dialog_for_photo_upload();
	},

	refresh_event_stream: function() {
		var $this = this, url, $events;
		if ( $this[0] ) {
			url = $this.metadata().url;
			$events = $this.find('div.events');
			if ( stream_interval ) clearInterval( stream_interval );
			stream_interval = setInterval(function() {
				$events.load( url );
			}, 20000);
		}
		return this;
	},

	request_invite: function() {
		return this.bind('click', function(event) {
			var $this = $(this), $li = $this.parent();
			$li.fadeTo('fast', 0, function() { $li.html('<span class="clicked">request sent</span>'); }).fadeTo('fast', 1);
			$.ajax({ url: $this.attr('href'), dataType: 'json', type: 'post' });
			return false;
		});
	},
	
	accept_invite: function() {
		return this.bind('click', function(event) {
			var $this = $(this);
			$.ajax({ url: $this.attr('href'), dataType: 'json', type: 'post',
				success: function(data) {
					if ( data["errors"] ) {
						for ( var i=0; i<data["errors"].length; i++ ) {
							$('#flash_error ul').append('<li>' + data["errors"][i] + '</li>');
							$('#flash_error').setup_notices();
						}
					} else 
						window.location.reload();
			}
			
			});
			return false;
		});
	},
	
	decline_invite: function() {
		return this.bind('click', function(event) {
			var $this = $(this);
			$.ajax({ url: $this.attr('href'), type: 'post', data: { '_method': 'delete' }, success: function() { window.location.reload(); } });
			return false;
		});
	},

	setup_alternate_photos: function() {
		return this.live('click', function(event) {
			var $this = $(this).blur();
			$.ajax({
				url: $this.attr('href'),
				dataType: 'html',
				type: 'post',
				success: function(data) {
					$('#photos').html(data);
				}
			});
			return false;
		});
	}, 
	
	setup_answer_form: function() {
		return this
		  .find('#answer_answer').focus().end()
			.find('input.recommend')
				.bind('click', function(event) {
					$('#recommend').val('true');
				})
			.end()
	},
	
	setup_blog_tags_autocomplete: function() {
		return this.each(function() {
			var $this = $(this), blog_tags = $this.parent().metadata().blog_tags;
			$this.autocomplete({ data: blog_tags, multiple: true, autoFill: true });
		});
	},

	setup_character_counter: function() {
		return this.livequery(function(){
			$(this).cube_countable();  //in lieu of countable corrects crlf count 
		});
	},
 
	setup_progressbar: function() {
	  return this.each(function() {
			$(this).progressBar({ showText: false, 
								   					width:200,
														height:12,
		                        boxImage: '/images/progressbar.gif',
		                        barImage: '/images/progressbg_green_1.gif'});
		});
	},
 
	// ckeditor is used in the following tool interfacess:
	// blog, system announcement, welcome email, About Us, 
	// Terms and condition 
	setup_ckeditor: function() {
		return this.each(function() {

			// MAM2: Don't use fckeditor for iphone/ipad
			if(navigator.userAgent.indexOf("iPhone") != -1 || navigator.userAgent.indexOf("iPod") != -1 || navigator.userAgent.indexOf("iPad") != -1) {
				var $this = $(this);
				// Don't setup fckeditor
			}
			else {						
				var $this = $(this);
			
				//jes Apr 2010: needs to be moved to ckcustom.js
				// issues of time have precluded completion of the move
				// will attempt in the next release 
				CKEDITOR.config.customConfig = '/javascripts/ckcustom.js';
		 	    CKEDITOR.config.height = $this.css('height');
			    CKEDITOR.config.resize_maxWidth = $this.css('width');
				CKEDITOR.config.skin = 'office2003';
 			
				CKEDITOR.config.toolbar = 'CubelessImpl';
				CKEDITOR.config.extraPlugins = "embed";
				CKEDITOR.replace( this );	
			}
		});
	},

	setup_filter_form: function() {
		return this
			.find('select')
				.livequery('change', function(event) {
					var $form = $(this).parents('form:first');
					if ( $form.is('.ajax') )
						$.ajax({
							url: $form.attr('action'),
							type: 'get',
							dataType: 'script',
							data: $form.serialize()
						});
					else
						$form.submit();
				})
			.end();
	},

	setup_flash: function() {
		return this.each(function() {
			var $this = $(this), data = $this.metadata();
			data.params.wmode = "opaque";
			swfobject.embedSWF(data.src, this.id, data.width, data.height, (data.version || "9.0.0"), (data.expressInstall || "/bin/playerProductInstall.swf"), data.flashvars, data.params, data.attributes);
		});
	},

	setup_follow_links: function() {
		return this.find('a').live('click', function(event) {
			var $this = $(this), $span = $this.parent();
			$span.fadeTo('fast', 0, function() {
				$span.removeClass('follow').addClass('clicked').html('following').fadeTo('fast', 1);
			});
			$.ajax({ url: $this.attr('href'), type: 'get', dataType: 'json' });
			return false;
		}).end();
	},
	
	setup_group_email_settings: function() {
		return this.each(function() {
			$(this)
				.accordion({
					active: $("#using_global").val() == "true" ? "#all_groups_preferences" : "#individual_group_preferences",
					header: '#all_groups_preferences, #individual_group_preferences',
					autoHeight: false
				})
				.find('input:submit').remove().end()
				.find('h4:not(.selected)').addClass('link').end()
				.append('<div class="buttons"><input type="submit" class="large button" value="Save Settings" name="commit" /></div>')
				.find('#all_groups_preferences, #individual_group_preferences')
					.bind('click', function(event) {
						$("#use_global_email_preferences")
							.val( $(this).is("#all_groups_preferences") ? "true" : "false" );
						$(this).find('h4').is(':not(.selected)') && $("#all, #individual").toggleClass('selected').toggleClass('link');
						this.blur();
					})
				.end();
				$('#use_global_email_preferences').val($('#using_global').val());
		});
	},

	setup_group_talk_form: function() {
		var $textarea = $('#group_post_post'),
			default_value = $textarea.attr('defaultValue'),
			default_text = "Ask your group a question, make a statement, take a poll just type away.";
		$textarea
			.val( default_value || default_text )
			.bind('focus', function() { this.select(); })
			.bind('blur', function() { if ( $.trim( $textarea.val() ) == "" ) $textarea.val( default_text ); });
		return this
			.bind('submit', function() {
				if ( $textarea.val() == default_text ) $textarea.val("");
			});
	},

	setup_inline_editor: function() {
		return this.each(function() {
			var $this = $(this), options = $this.metadata();
			$this
				.find('script').remove().end()
				.bind('editing.jeditable submitting.jeditable resetting.jeditable', function() {
					$('#tooltip').hide();
					$.tooltip.block();
				})
				.editable( function(value, settings) {
					var data = { '_method': 'put' };
					data[ settings.object + '[' + settings.name + ']' ] = value;
					$.ajax({
						url: settings.url,
						type: 'post',
						dataType: 'json',
						data: data,
						success: function(json) {
							$this.fadeTo('fast', 0, function() {
								var result = json[ settings.object ][ settings.name ];
								if ( $.isArray(result) ) result = result.join(', ');
								$this.html( result.replace(/\n/g, '<br>') || settings.placeholder ).fadeTo('fast', 1);
							});
						}
					});
					return 'Saving...';
				}, $.extend({
					submit: '<input type="submit" name="commit" value="Save" class="button medium">',
					cancel: '<input type="reset" name="reset" value="Cancel" class="button medium light">',
					onblur: 'ignore',
					cssclass: 'inline_edit',
					placeholder: 'Click here to edit'
				}, options) );
		});
	},

	setup_member_wall: function() {
		$('#member_scrollers').setup_member_wall_scrollers();
		$('table', this).bind('click', function(event) {
			var $a = $(event.target).parents('td:first').find('a:first').blur();
			if ( $a.length == 0 ) return false;
			$('#member_card').fadeTo('normal', 0);
			$.ajax({
				url: document.location.href.replace('members', 'select_member'),
				type: 'get',
				dataType: 'html',
				data: { selected: $a.attr('href').match(/\d+$/)[0] },
				success: function(data) {
					$('#member_card').replaceWith(data).fadeTo('normal', 1);
				}
			});
			return false;
		});
		return this;
	},

	setup_member_wall_scrollers: function() {
		if ( this[0] ) check_widths();
		return this
			.find('a')
				.bind('click', function(event) {
					var direction = $(this).is('.next') ? 1 : -1;
					$('#members_images:not(:animated)').animate({ scrollLeft: $('#members_images').scrollLeft() + (86*direction) }, 'fast', check_widths);
					this.blur();
					return false;
				})
			.end();

		function check_widths() {
			var $images = $('#members_images'),
				scrollLeft = $images.scrollLeft(),
				width = $images[0].scrollWidth - $images.width();
			$('#member_scrollers')
				.find('a.previous')[ scrollLeft == 0 ? 'fadeOut' : 'fadeIn' ]('fast').end()
				.find('a.next')[ width == scrollLeft ? 'fadeOut' : 'fadeIn' ]('fast');
		};
	},

	setup_name_autocomplete: function(options) {
		return this.each(function() {
			$(this)
				.bind('focus', function(event) { this.select(); })
				.autocomplete($.extend({
					url: options.url,
					minChars: 3,
					formatResult: function(row) { return row[1]; }
				}, options || {}))
				.bind('result', function(event, data, formatted) {
					$(this).parents('form')
						.find(':hidden.suggestion_id').val( data[2] ).end()
						.find(':hidden.suggestion_type').val( data[3] ).end();
				});
		});
	},

	setup_notices: function() {
		return this.each(function() {
			var $this = $(this), timeout;
			if ( !$this.has('ul li') ) return;
			$this
				.dialog({
					dialogClass: $this.is('.notice') ? 'notice_dialog' : 'error_dialog',
					draggable: false, bgiframe: true, width: null, height: 'auto', minHeight: 0
				})
				.bind('mouseenter mouseleave', function(event) {
					if ( event.type == 'mouseenter' ) clearTimeout(timeout);
					else timeout = setTimeout(function() { $this.dialog('destroy').css('display', '').find('ul').empty(); }, 500);
				});
			timeout = setTimeout(function() { $this.dialog('destroy').css('display', '').find('ul').empty(); }, 2000);
		});
	},

	setup_question_datepicker: function() {
		var html = '&nbsp;<a href="#">change date</a><div id="question_close_datepicker"/>';
		return this.append( html )
			.find('div')
				.hide()
				.datepicker({
					defaultDate: '+30d', minDate: '+1d', maxDate: '+1y',
					dateFormat: 'MM dd, yy', altFormat: 'MM dd, yy',
					altField: '#question_open_until', hideIfNoPrevNext: true,
					onSelect: function(dateText) {
						$('#question_close_date').fadeOut(function() { $(this).text( dateText ).fadeIn(); });
						$('#question_close_datepicker').toggle('normal');
					}
				})
			.end()
			.find('a:first')
				.bind('click', function(event) {
					$('#question_close_datepicker:not(:animated)').toggle('normal');
					this.blur();
					return false;
				})
			.end();
	},

	setup_rating: function() {
		return this
			.bind('mouseover mouseout', function(event) {
				$(this).toggleClass( 'rate_hover' + ($(this).is('.my_rating') ? '_my_rating' : '') );
			})
			.find('a')
				.live('click', function(event) {
					var $this = $(this).blur(), $div = $this.parents('div.rate');
					$div.find('p').html('Saving...');
					$div.find('a').removeClass('selected');
					$this.addClass('selected');
					$.ajax({
						url: $this.attr('href'), dataType: 'html', type: 'post',
						success: function(data) {
							$div.html(data);
						}
					});
					return false;
				})
			.end();
	},

	setup_select_moderator_option_links: function(title) {
		return this.live('click', function() {
			var $this = $(this);
			$.ajax({ url: $this.attr('href'), type: 'post',
				success: function(data) {
					$('#moderator_settings').html(data);
				}
			});
			return false;
		});
	},

	setup_start_end_datepickers: function(options) {
		return this.datepicker($.extend({
			dateFormat: 'MM dd, yy',
			hideIfNoPrevNext: true,
			constrainInput: true
		}, options));
	},

	setup_start_end_datepickers_for_announcement: function() {
		var $this = $(this), $start = $this.filter('.start'), $end = $this.filter('.end');
		return this.setup_start_end_datepickers({
			beforeShow: function(input) {
				return {
					minDate: $(input).is('.end') ? $start.datepicker('getDate') : null,
					maxDate: $(input).is('.start') ? $end.datepicker('getDate') : null
				};
			}
		});
	},

	setup_tooltips: function() {
		return this.livequery(function() {
			$(this).tooltip({ track: true, showURL: false });
		});
	},

	setup_vote_answer_links: function() {
		return this.live('click', function(event) {
			var $this = $(this), $answer = $this.parents('.answer:first'), $vote = $answer.find('.vote_wrap');
			$vote.fadeTo('fast', 0);
			$.ajax({ 
				url: $this.attr('href'), type: 'post', dataType: 'html',
				success: function(data) {
					$vote.html(data).fadeTo('fast', 1);
				}
			});
			return false;
		});
	},

	setup_watch_links: function() {
		return this.find('a').live('click', function(event) {
			var $this = $(this), $span = $this.parent();
			$span.fadeTo('fast', 0, function() {
				$span.removeClass('watch').addClass('clicked').html('watching').fadeTo('fast', 1);
			});
			$.ajax({ url: $this.attr('href'), type: 'get', dataType: 'json' });
			return false;
		}).end();
	},

	sortable_hub_widgets: function() {
		return this
			.find('.hub_widgets_col_1, .hub_widgets_col_2')
				.sortable({
					containment: '#hub_widgets', items: 'div.widget', handle: 'div.header', opacity: 0.75,
					connectWith: ['.hub_widgets_col_1, .hub_widgets_col_2'],
					helper: function(event, item) { return $(item).clone().find('.content').remove().end(); },
					start: function() { if ( stream_interval ) clearInterval( stream_interval ); },
					stop: function() { 
						$('#event_stream').refresh_event_stream();
						$.ajax({
							url: '/profiles/update_widget_sequence', type: 'post',
							data: $('.hub_widgets_col_1').sortable('serialize', { key: 'group1[]' }) + '&' + $('.hub_widgets_col_2').sortable('serialize', { key: 'group2[]' })
						});
					}
				})
			.end()
			.find('a.refresh')
				.bind('click', function(event) {
					var $this = $(this).blur();
					var $content = $this.parents('div.widget:first').find('div.content');
					$content.addClass('loading').find('#avatar_cloud').fadeTo('normal', 0);
					$.ajax({
						url: this.href, type: 'get', dataType: 'html',
						success: function(data) {
							$content.removeClass('loading').html(data).fadeTo('fast', 1);
						}
					});
					return false;
				})
			.end()
			.find('a.toggle')
				.bind('click', function(event) {
					$( this ).blur().parents('div.widget').toggleClass('collapsed');
					$.ajax({ url: this.href, type: 'post', data: this.search.substr(1) });
					return false;
				})
			.end();
	},

	submit_on_enter_keydown: function() {
		return this.bind('keydown', function(event) {
			if ( event.keyCode == 13 ) this.form.onsubmit();
		});
	}

});

$.confirmation_dialog = function(options) {
	options = $.extend({
		title: 'Are you sure?',
		body: '',
		yes: function() {  },
		no: function() {  }
	}, options);
	var $dialog = $('<div><h3>' + options.title + '</h3>' + options.body + '<div class="buttons"><input type="button" class="button medium yes" value="Yes"><input type="button" class="button medium light close no" value="No"></div>')
		.dialog({
			dialogClass: 'popup confirmation', modal: true, bgiframe: true, draggable: false, width: null, height: 'auto', minHeight: 0
		})
		.find('input.button').bind('click', function(event) {
			var $this = $(this);
			if ( $this.is('.yes') )
				options.yes();
			else if ( $this.is('.no') )
				$dialog.dialog('destroy').remove();
				options.no();
		}).end();
	return $dialog;
};


// Always send the authenticity_token with ajax
$(document).ajaxSend(function(event, request, settings) {
	if ( settings.type == 'post' ) {
		settings.data = (settings.data ? settings.data + "&" : "") + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
		request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	}
});

// When I say html I really mean script for rails
$.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

// Set metadata default to script
$.metadata.setType('elem', 'script');

// Titlecase method
String.prototype.titleCase = function () {
	var str = "";
	var wrds = this.split(" ");
	for(keyvar in wrds)
	{
	str += ' ' + wrds[keyvar].substr(0,1).toUpperCase()
	 + wrds[keyvar].substr(1,wrds[keyvar].length);
	}
   return str;
}


})(jQuery);