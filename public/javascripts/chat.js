if(typeof(PostQueue)=='undefined') PostQueue = {};
PostQueue.queue_name = "postPolling";
PostQueue.queue = function(f) {
  $(document).queue(PostQueue.queue_name, f);
};
PostQueue.dequeue = function() {
  $(document).dequeue(PostQueue.queue_name);  
};
PostQueue.clear_queue = function() {
  $(document).queue(PostQueue.queue_name, []);  
};


//
// Chat
//
if(typeof(Chat)=='undefined') Chat = {};
Chat.container = function() { return $('#chat_container'); };
Chat.discussion_container = function() { return $('div#chat_discuss'); };
Chat.queue_container = function() { return $('div#chat_queue_container'); };
Chat.participants_container = function() { return $('div#chat_participants'); };
Chat.participants_polling_link = function() { return $('a#participants_polling_link'); };
Chat.poll_participants = function() {
  $.ajax({ url:Chat.participants_polling_link().attr('href'), type:'GET', dataType:'html',
            success:function(data) {
              Chat.participants_container().html(data);
            }
          });
}


//
// Topic
//
if(typeof(Topic)=='undefined') Topic = {};
Topic.list = function() { return $('div#chat_queue div#question_bin ul:first'); };
Topic.queued_link = function() { return $('a#queued_topics_link'); };
Topic.queued_loading = function() { return $('div#chat_queue_loading'); };
Topic.add = function(html) {
  Topic.list().append(html);                  
};
Topic.remove = function(element_id) {
  Topic.list().find('li#' + element_id).remove();
};

Topic.polling_link = function() { return $('a#topic_polling_link'); };
Topic.update_polling_link = function() {
  since_id = Topic.list().find('li:last').length > 0 ? Topic.list().find('li:last').attr('id').replace("topic_","") : "";
  Topic.polling_link().attr('href', Topic.polling_link().attr('href').replace(/since_id=\d*/, "since_id=" + since_id))                  
};

// Poll for topics
// There is a BIG assumption here that the topics are coming back in id ASC order
// This works great for adding new topics, not great for ordering
// If you want to do reordering, that needs to be a seperate method
Topic.poll = function() {
  $.ajax({ url:Topic.polling_link().attr('href'), type:'GET', dataType:'html',
            success:function(data) {
              Topic.add(data);
              Topic.update_polling_link();
            }
          });
};

// Discuss and change topics
Topic.discuss = function(topic) {
  $topic = $(topic);
  
  $.ajax({ url:$topic.attr('href'), type:'POST', dataType:'json',
            beforeSend:function() {

            },
            success:function(data) {
              if(data["errors"]){
                // $this.find('div.error').remove();
                // $this.prepend('<div class="error">There was an error in your submission. Please try again or contact support.</div>');
              }
              else {
                ActiveTopic.poll();
              }
            },
            complete:function() {

            }
        });
};

Topic.change_active = function(data) {    
  // TODO: Check to see if using a local copy of the present discussion is a bad idea.
  // Do we need to do one last poll? Cut off all outstanding polls?
  
  // Make the present discussion a past discussion
  $stale_container = $('div#chat_discuss div#present_discussion_container');
  $h3 = $stale_container.find('h3:first');
  $h3.find('strong:first').remove();

  $h3.addClass('past');

  // $stale_container.find('div:first').hide();
  $stale_container.find('#post_polling_link').remove();
  stale_present_html = $stale_container.html();
                       
  // $('div#chat_discuss div.accordion').prepend(stale_present_html);
  $('div#past_discussions').prepend(stale_present_html);
  $("div#past_discussions").accordion("destroy");
  $("div#past_discussions").accordion({ active:false, collapsible:true });
    
  ActiveTopic.present_container().remove();
  
  // Insert the new present discussion
  // Chat.discussion_container().append(data);
  Chat.discussion_container().prepend(data);
  
  // Remove the listing from the queue
  new_topic_id = $(data).find('h3:first > a:first').attr('href').split("_")[1];
  Topic.remove("topic_" + new_topic_id);
};
Topic.last_post_id = function(container) { 
  if(container.find('tr:last').attr('id')) {
    return(parseInt(container.find('tr:last').attr('id').replace("post_","")));
  }
  else {
    return 0;
  }
};
Topic.add_posts_from_json = function(container, last_post_id, json, options) {
  $.each(json, function(idx, post) {
    //alert(post["post"]["display_name"]);
    Topic.add_post(container, last_post_id, post["post"]["id"], post["post"]["display_name"], post["post"]["html_body"], post["post"]["host?"], options);
    //alert("done");
  });
};
Topic.add_post = function(container, last_post_id, id, name, text, is_host, options) {
  // Extra check on duplicate posts
  if(last_post_id != id) {
    display_name = Topic.determine_post_display_name(container, name);

    container.append(Topic.build_post_row(id, display_name, text, is_host));  
  }
}
Topic.build_post_row = function(id, name, text, is_host) {
  $row = $(document.createElement('tr'));
  $row.attr('id', 'post_' + id);
  if(is_host) {
    $row.addClass("host")
  }
  
  $td_name = $(document.createElement('td'));
  $td_name.html(name);
  if(name != "") {
    $td_name.addClass("name");
  }
  
  $td_text = $(document.createElement('td'));
  $td_text.html(text);
  
  $row.append($td_name);
  $row.append($td_text);
  
  return $row;
}
Topic.determine_post_display_name = function(container, name) {

  // MM2: I'd love to avoid loading the whole chat....but it's good enough for now
  $(container.find('tr > td:first-child').get().reverse()).each(function() {
    $td = $(this);

    if(jQuery.trim($td.html()) == "") {
      return true;
    }
    else {
      if($td.html() == name) {
        name = "";
        //return true;
        return false;
      }
      else {
        return false;
      }
    }
  });

  return name;
};
Topic.fetch_queued = function() {
  
  $.ajax({url:Topic.queued_link().attr('href'), type:'GET', dataType:'html',
          success:function(data) {
            Topic.queued_loading().remove();
            
            if (Chat.queue_container().find('div:first').html() != $(data).html()) {
              Chat.queue_container().find('div#chat_queue').remove();
              Chat.queue_container().find('h3:first').after(data);
              $("div.accordion_open").accordion({ collapsible:true });
            }
            
          }
  });
};
Topic.vote = function(topic) {
  $this = $(topic);
  $parent = $this.parent();
  
  $.ajax({  url:$this.attr('href'), type:'POST', dataType:'json',
            beforeSend:function() {
              $parent.html("Saving Vote...");
            },
            success:function(data) {
              if(data["errors"]) {
                $parent.html("Error in Saving Vote.");
              }
              else {
                $parent.html("Voted " + data["direction"]);
              }
            },
            error:function() {
              // MM2: This really doesn't happen as our Rails app catches errors and returns an error page.
              $parent.html("Error in Saving Vote.");
            }  
          });
};
Topic.host_vote_polling = function(flag) {
  if(flag == true) {
    setInterval(function() {
      Topic.fetch_queued();
    }, 10000);
  }
};



//
// Active Topic
//
if(typeof(ActiveTopic)=='undefined') ActiveTopic = {};
ActiveTopic.present_container = function() { return $('div#chat_discuss div#present_container'); };
ActiveTopic.tbody = function() { return $('table#present_discussion:first > tbody:first'); };
ActiveTopic.title = function() { return ActiveTopic.present_container().find('h3').html().replace(/<strong>.*<\/strong>\s*/,""); };
ActiveTopic.last_post_id = function() { 
  return Topic.last_post_id(ActiveTopic.tbody());
};
ActiveTopic.add_posts_from_json = function(json, options) {
  Topic.add_posts_from_json(ActiveTopic.tbody(), ActiveTopic.last_post_id(), json, options);
  
  if(options["delay_scroll"] != true) {
    ActiveTopic.scroll();
  }
};
ActiveTopic.add_post = function(id, name, text, is_host, options) {
  Topic.add_post(ActiveTopic.tbody(), ActiveTopic.last_post_id(), id, name, text, is_host, options);
  
  if(options["delay_scroll"] != true) {
    ActiveTopic.scroll();
  }
};
ActiveTopic.build_post_row = function(id, name, text, is_host) {  
  return Topic.build_post_row(id, name, text, is_host)
};
ActiveTopic.determine_post_display_name = function(name) {  
  return Topic.determine_post_display_name(ActiveTopic.tbody(), name);
};
// Poll for active topic
// Checks to see if the active topic has changed 
ActiveTopic.polling_link = function() { return $('a#active_topic_polling_link'); };
ActiveTopic.update_polling_link = function(new_active_id) {
  ActiveTopic.polling_link().attr('href', ActiveTopic.polling_link().attr('href').replace(/active_id=\d*/, "active_id=" + new_active_id))                  
};
ActiveTopic.poll = function() {
  $.ajax({ url:ActiveTopic.polling_link().attr('href'), type:'GET', dataType:'json',
            success:function(data) {
              if(data["new_active_topic"]) {
                //Topic.setup_as_active(data);
                
                $status_overlay = $(document.createElement('div'));
                $status_overlay.attr('id', 'status_overlay');
                
                json_data = data;
                
                $.ajax({ url:data["topic_discussion_url"], type:'GET', dataType:'html',
                          beforeSend:function() {
                            overlay_html = "<h2>Changing Topics</h2>";
                            $status_overlay.html(overlay_html);

                            $status_overlay.dialog({ modal: true, draggable: false, width: null, height: 'auto', minHeight: 0, dialogClass:'popup' })
                          },
                          success:function(data) {
                            if(data == "error"){
                              // $this.find('div.error').remove();
                              // $this.prepend('<div class="error">There was an error in your submission. Please try again or contact support.</div>');
                            }
                            else {
                              Topic.change_active(data);
                              ActiveTopic.update_polling_link(json_data["active_id"]);
                            }
                          },
                          complete:function() {
                            setTimeout(function() {     $('#status_overlay').remove(); }, 2000)
                          }
                      });
              }
            }
          });
};
ActiveTopic.scroll = function() {
  $('div#present_discussion_container > div:first > div:first').animate({
      scrollTop: $('table#present_discussion').height()
  });
}


//
// Post
//
if(typeof(Post)=='undefined') Post = {};
Post.form = function() { return $('form#new_post_form'); };
Post.form_disable = function() {
  Post.form().find('input:submit, textarea').attr('disabled','disabled');
};
Post.form_enable = function() {
  Post.form().find('input:submit, textarea').attr('disabled','');
  Post.textarea().focus();
};

Post.textarea = function() { return $('textarea#present_discussion_text'); };
Post.submit = function() {
  PostQueue.clear_queue();
  
  $.ajax({  url:Post.form().attr('action'), type:'POST', dataType:'json', data:Post.form().serialize(),
            beforeSend:function() {
              Post.form_disable();
            },
            success:function(data) {
              Post.poll();
              PostQueue.dequeue();
              
              Post.textarea().val('');
            },
            complete:function() {
              Post.form_enable();
            }


  });
};

Post.polling_link = function() { return $('a#post_polling_link'); };
Post.update_polling_link = function() {
  since_id = ActiveTopic.tbody().find('tr:last').attr('id').replace("post_","");
  Post.polling_link().attr('href', Post.polling_link().attr('href').replace(/since_id=\d*/, "since_id=" + since_id))                  
};

// Poll for posts
// There is a BIG assumption here that the posts are coming back in id ASC order
// This works great for adding new posts, not great for ordering
// If you want to do reordering, that needs to be a seperate method

// Also, we will move this to a cgi at some point...example below

// TODO: Ensure no open ajax calls are hanging
Post.poll = function() {
  // HTML attempt...but we are probably going for something more json-y
  // $.ajax({ url:Post.polling_link().attr('href'), type:'GET', dataType:'html',
  //           success:function(data) {
  //             ActiveTopic.tbody().append(data);
  //             Post.update_polling_link();
  //           }
  //         });
  
  // JSON attempt...good for starters  
  PostQueue.queue(function() {
    $.ajax({ url:Post.polling_link().attr('href'), type:'GET', dataType:'json',
              success:function(data) {
                if(data) {
                  ActiveTopic.add_posts_from_json(data,{});
                }
                Post.update_polling_link();
              },
              complete:function() {
                PostQueue.dequeue();
              }
            });
  });


  // CGI / JSONP attempt...most likely where we're headed
  // $.ajax({ url:'http://mark.local/cgi-bin/hello_world.cgi', dataType:'jsonp',
  //           success:function(data) {
  //             if(data["errors"]) {
  //               
  //             }
  //             else if(data["posts"]) {
  //               $.each(data["posts"], function(idx, chat_hash) {
  //                 ActiveTopic.add_post(chat_hash["id"], chat_hash["name"], chat_hash["text"]);
  //               });
  //             }
  //             else {
  //               
  //             }
  //           },
  //           complete:function(XMLHttpRequest, textStatus) {
  //             // alert('Complete');
  //             // alert(textStatus);
  //             // alert(XMLHttpRequest);
  //           }
  // });

};

//
// jQuery behaviors
//

function set_send_notification_emails()  {
  // SSJ 2-21-2011 - this is for display purposes only -- controller will send an email update if the start_at has changed
  $("form input#email_notifications").attr('checked', true);
	$("form input#email_notifications").attr('disabled', true);
};

(function($) {  // $ = jQuery within this block
	$(document).ready(function() {
	  // RSVP for a chat
    $('a.rsvp_link').live('click', function(event) {
      $this = $(this);
      $.ajax( { url:$this.attr('href'), dataType:'html', type:'POST',
                success:function(data) {
                  $this.replaceWith(data);
                }
              });

      return false;
    }),
	  
	  // DELETE for a topic (only in show window)
    $('a.delete_topic').live('click', function(event) {
      $this = $(this);
      $.ajax( { url:$this.attr('href'), dataType:'html', type:'POST', data:"_method=delete",
                success:function(data) {
                  $this.parent().parent().replaceWith(data);
                }
              });

      return false;
    }),
	  
	  // CREATE for a topic (only in show window)
    $('form#create_topic').bind('submit', function(event) {
      $this = $(this);
      $submit_label = $this.find('input[type=submit]:first').val();
      $.ajax({ url:$this.attr('action'), type:'POST', dataType:'html', data:$this.serialize(),
                beforeSend:function() {
                  $this.find('input').attr('disabled', true);
                  $this.find('input[type=submit]:first').val('Submitting...');
                },
                success:function(data) {
                  if(data == "error"){
                    $this.find('div.error').remove();
                    $this.prepend('<div class="error">There was an error in your submission. Please try again or contact support.</div>');
                  }
                  else {
                    $this.find('input#topic_title').val('');
                    $('ul#topic_list').append(data);
                  }
                },
                complete:function() {
                  $this.find('input').attr('disabled', false);
                  $this.find('input[type=submit]:first').val($submit_label);
                }
            });
            
      return false;
    }),
	  
	  // DATE PICKER for New / Edit chat
	  $("form div.future_datepicker").datepicker({
			dateFormat: 'yy-mm-dd',
			minDate: 0,
      // defaultDate: new Date('1 January 2012'),
			onSelect: function(dateText, inst) { 
				$("form input#chat_start_at").val(dateText);
				set_send_notification_emails();
			}
		}),
		
		// SSJ SET date of date_picker -- this only needs to run in chats/edit
		// if ($('form input#chat_start_at').length > 0){ 
		//      $start_date = $("form input#chat_start_at").val();
		//      if($start_date) {
		//        $start_date = $start_date.split(" ")[0];
		//         $myDateParts = $start_date.split("-");
		//         $myJSDate = new Date($myDateParts[0], $myDateParts[1]-1, $myDateParts[2]);
		//         $("form div.future_datepicker").datepicker( "setDate" , $myJSDate );
		//       }
		//     },  
    
    // Change Start time
    $('select#start_hour, select#start_minutes, select#time_zone').change( function() {
      set_send_notification_emails();
    }),
    
    
    // Accordion for new topic
    $("div.accordion").accordion({ active:false, collapsible:true }),
    $("div.accordion_open").accordion({ collapsible:true }),
    
    
    // Submitting a new question
    $('form#new_chat_question_form').live('submit', function(event) {
      $this = $(this);
      $new_question = $this.find('textarea').val()
      $.ajax({ url:$this.attr('action'), type:'POST', dataType:'html', data:$this.serialize(),
                beforeSend:function() {
                  // remove error div before submitting again
                  if ($this.find('div.error')){
                    $this.find('div.error').remove();
                  }
                  
                  // SSJ: dont submit if the form is blank
                  if (!$new_question) {
                    return false;
                  }
                  
                  $this.find('input').attr('disabled', true);
                  $this.find('input[type=submit]:first').val('Submitting...');
                },
                success:function(data) {
                  if(data == "error"){
                    $this.find('div.error').remove();
                    $this.prepend('<div class="error">There was an error in your submission. Please try again or contact support.</div>');
                  }
                  else {
                    $this.find('textarea').val('');
                    $('div#chat_queue div.accordion a:first').trigger('click');
                    
                    Topic.poll();
                    
                    // TODO: Some kind of highlight of the added question
                  }
                },
                complete:function() {
                  $this.find('input').attr('disabled', false);
                  $this.find('input[type=submit]:first').val('Submit');
                }
            });
            
      return false;
    }),
    
    // Question voting
    $('#question_bin a.vote').live('click', function(event) {
      Topic.vote($(this));
      return false;
    }),
    
  
    // Toggling past discussions
    // $('div#chat_discuss div.accordion h3 a').live('click', function(event) {
    //   $this = $(this);
    //   $toggle = $this.find('small:first')
    //   $toggle.html() == "(expand)" ? $toggle.html('(collapse)') : $toggle.html('(expand)');
    //   
    //   // MM2: Do NOT return false. This action needs to keep going for the accordion toggle to kick in.
    // }),
    
    // Toggling past discussions from the question queue
    // TODO: Be mindful of the of the state of these things. A click then another can be very unintuative.
    $('div#chat_queue a.past_link').live('click', function(event) {      
      $this = $(this);
      $toggle = $this.find('small:first')
      $toggle.html() == "(expand)" ? $toggle.html('(collapse)') : $toggle.html('(expand)');
      
      // Hide other accordions
      $('div#chat_discuss div.accordion h3.past').hide();
      
      // Show and Trigger the correct accordion
      target_trigger_id_array = $this.attr('id').split("_");
      target_trigger_id_array.pop();
      target_trigger_id = target_trigger_id_array.join("_");
      $('a#' + target_trigger_id).parent().show();
      $('a#' + target_trigger_id).trigger('click');
      
      return false;
    }),


    // TODO: Make work for all topics
    $('div.past_container').each(function() {
      $this = $(this);
      
      id = $this.attr('id').split("_")[1];      
      container = $this.find('table:first tbody:first');
            
      Topic.add_posts_from_json(container, Topic.last_post_id(container), discussion_posts[id]);
    });



		
});

	
	$.fn.extend({    	

  });
  
})(jQuery);

