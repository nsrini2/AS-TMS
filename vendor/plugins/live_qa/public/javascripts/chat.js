//
// Chat
//
if(typeof(Chat)=='undefined') Chat = {};


//
// Topic
//
if(typeof(Topic)=='undefined') Topic = {};
Topic.list = function() { return $('div#chat_queue div#question_bin ul:first'); };
Topic.add = function(html) {
  Topic.list().append(html);                  
};

Topic.polling_link = function() { return $('a#topic_polling_link'); };
Topic.update_polling_link = function() {
  since_id = Topic.list().find('li:last').attr('id').replace("topic_","");
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

//
// Active Topic
//
if(typeof(ActiveTopic)=='undefined') ActiveTopic = {};
ActiveTopic.tbody = function() { return $('table#present_discussion > tbody:last'); };
ActiveTopic.add_posts_from_json = function(json) {
  $.each(json, function(idx, post) {
    ActiveTopic.add_post(post["post"]["id"], post["post"]["display_name"], post["post"]["body"]);
  });
};
ActiveTopic.add_post = function(id, name, text) {    
  ActiveTopic.tbody().append(ActiveTopic.build_post_row(id, name, text));  
  
  // TODO: Fix buggy scroll on first post
  // Scroll to the bottom
  //$new_last_row = $tbody.find('tr:last-child');
  //$('#present_container > div:first').scrollTo($new_last_row, {offset:{top:$new_last_row.height(),left:0}});
  
  // TODO: Add scrollto plugin
  // $('div#present_container > div:first').scrollTo($('table#present_discussion').height());
};
ActiveTopic.build_post_row = function(id, name, text) {
  display_name = ActiveTopic.determine_post_display_name(name);
  
  // tr_start = "<tr id=\"post_" + id + "\">";
  // td = "<td>" + display_name + '</td><td>' + text + "</td>";
  // tr_end = "</tr>";
  // row = tr_start + td + tr_end;
  
  $row = $(document.createElement('tr'));
  $row.attr('id', 'post_' + id);
  
  $td_name = $(document.createElement('td'));
  $td_name.html(display_name);
  
  $td_text = $(document.createElement('td'));
  $td_text.html(text);
  
  $row.append($td_name);
  $row.append($td_text);
  
  return $row;
};
ActiveTopic.determine_post_display_name = function(name) {  
  // Only works for every other...do better
  // ActiveTopic.tbody().find('tr:last-child > td:first-child').html() == name ? "" : name;
  
  // That's better.
  // Still, I'd love to avoid loading the whole chat....
  $(ActiveTopic.tbody().find('tr > td:first-child').get().reverse()).each(function() {
    $td = $(this);
    
    if($td.html().trim() == "") {
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


//
// Post
//
if(typeof(Post)=='undefined') Post = {};
Post.form = function() { return $('form#new_post_form'); };
Post.form_disable = function() {
  Post.form().find('input:submit, textarea').attr('disabled','disabled');
  return false;
};
Post.form_enable = function() {
  Post.form().find('input:submit, textarea').attr('disabled','');
  return false;
};

Post.textarea = function() { return $('textarea#present_discussion_text'); };
Post.submit = function() {
  $.ajax({  url:Post.form().attr('action'), type:'POST', dataType:'json', data:Post.form().serialize(),
            beforeSend:function() {
              Post.form_disable();
            },
            success:function(data) {
              Post.poll();
              Post.textarea().val('');
              Post.textarea().focus();
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
  $.ajax({ url:Post.polling_link().attr('href'), type:'GET', dataType:'json',
            success:function(data) {
              if(data) {
                ActiveTopic.add_posts_from_json(data);
              }
              Post.update_polling_link();
            }
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

(function($) {  // $ = jQuery within this block
  
	$(document).ready(function() {
	  
	  // HTML 5 placeholders
	  $('form.html5').html5form_custom(),
	  
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
                  $this.parent().replaceWith(data);
                }
              });

      return false;
    }),
	  
	  // CREATE for a topic (only in show window)
    $('form#create_topic').bind('submit', function(event) {
      $this = $(this);
      
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
                    // alert(data);
                    $('ul#topic_list').append(data);
                  }
                },
                complete:function() {
                  $this.find('input').attr('disabled', false);
                  $this.find('input[type=submit]:first').val('Submit');
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
			}
		})
		
		// SSJ SET date of date_picker -- this only needs to run in chats/edit
		$start_date = $("form input#chat_start_at").val();
		if($start_date) {
		  $start_date = $start_date.split(" ")[0]
      $myDateParts = $start_date.split("-")
      $myJSDate = new Date($myDateParts[0], $myDateParts[1]-1, $myDateParts[2]);
      $("form div.future_datepicker").datepicker( "setDate" , $myJSDate );
    }
    
    // Accordion for new topic
    $("div.accordion").accordion({ active:false, collapsible:true }),
    
    
    // Submitting a new question
    $('form#new_chat_question_form').bind('submit', function(event) {
      $this = $(this);
      
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
    $('a.vote').live('click', function(event) {
      $this = $(this);
      $parent = $this.parent()
      
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
                }  });
      return false;
    }),
    
  
    // Toggling past discussions
    $('div#chat_discuss div.accordion h3 a').live('click', function(event) {
      $this = $(this);
      $toggle = $this.find('small:first')
      $toggle.html() == "(expand)" ? $toggle.html('(collapse)') : $toggle.html('(expand)');
      
      // MM2: Do NOT return false. This action needs to keep going for the accordion toggle to kick in.
    });
    
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
    });

		
});
	
	$.fn.extend({    	

  });
})(jQuery);