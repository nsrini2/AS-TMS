(function($) {  // $ = jQuery within this block
  
	$(document).ready(function() {
	  //
	  // IN CHAT FUNCTIONS
    //

    // Scrolling on page load
    // $.scrollTo('div#present_container'),
    // $('div#present_container > div:first').scrollTo($('table#present_discussion').height()),

    // TODO: Display accordion on present conversation
    // Showing present conversation on page load
    $('div.present').show(),
    
    // Setup topic polling every 10 seconds
    setInterval(function() { Topic.poll(); }, 10000),
    
    // Setup chat polling every 3 seconds
    setInterval(function() { Post.poll(); }, 3000),
    
    // Load the posts from scripts varaible
    ActiveTopic.add_posts_from_json(discussion_posts);
    
    // Choosing a question to discuss
    $('a.discuss_now').live('click', function(event) {
      $this = $(this);
      
      $this_queue = $this.parent().parent();
      
      $.ajax({ url:$this.attr('href'), type:'POST', dataType:'html', data:"text=" + $this_queue.find('div:first').html(),
                beforeSend:function() {
                  // alert('sending');
                },
                success:function(data) {
                  if(data == "error"){
                    // $this.find('div.error').remove();
                    // $this.prepend('<div class="error">There was an error in your submission. Please try again or contact support.</div>');
                  }
                  else {
                    // Edit the queue
                    // $stale_queue = $('div#chat_queue ol li.present');
                    //                     $stale_queue.addClass('past');
                    //                     $stale_queue.removeClass('present');
                    
                    $this_queue.addClass('present')
                    $this_queue.find('div.voting').remove();
                    
                    //$this_queue.insertAfter($stale_queue);
                    
                    // TODO: Know this will NOT work correctly in production. Using a local copy of the present discussion is a bad idea.
                    // Make the present discussion a past discussion
                    // $stale_container = $('div#chat_discuss div#present_discussion_container');
                    //                     $h3 = $stale_container.find('h3:first');
                    //                     $h3.find('strong:first').remove();
                    //                     $h3.append('<small>(expand)</small>');
                    //                     $h3.addClass('past');
                    //                     $stale_container.find('div:first').hide();
                    //                     stale_present_html = $stale_container.html();
                    //                     
                    //                     $('div#chat_discuss div.accordion').append(stale_present_html);
                    $('div#chat_discuss div#present_container').remove();
                    
                    // Insert the new present discussion
                    $('div#chat_discuss').append(data);
                  }
                },
                complete:function() {
                  // alert('complete');
                }
            });
      
      return false;
    }),
    


    // Send posts
    Post.form().live('submit', function(event) {
      Post.submit();
      
      return false;
    });
    

    //
    // Dummy functions
    //
    
    // Setup dummy question adding
    // setInterval(function() {
    //   $.ajax({ url:'/mocks/new_question', type:'POST', dataType:'html', data:$('form#new_chat_question_form').serialize(),
    //             success:function(data) {
    //               $('div#chat_queue div#question_bin ol:first').append(data);                  
    //             }
    //           });
    // 
    // }, 7000),
    
    // Setup dummy voting incrementing
    // setInterval(function() { 
    //     $votes = $('div.voting:last span.vote_up');
    //     votes_int = parseInt($votes.html().replace(/<\\?b>/,""));
    //     new_votes_int = votes_int + 10;
    //     $votes.html("<b>"+ new_votes_int + "</b>");
    //     
    //     setTimeout(function() {
    //       $('div.voting:last span.vote_up').html($('div.voting:last span.vote_up b').html());
    //     }, 2000);
    //   }, 3000
    // ),
    // setInterval(function() { 
    //     $votes = $('div.voting:first span.vote_down');
    //     votes_int = parseInt($votes.html());
    //     new_votes_int = votes_int + 4;
    //     $votes.html("<b>"+ new_votes_int + "</b>");
    //     
    //     setTimeout(function() {
    //       $('div.voting:first span.vote_down').html($('div.voting:first span.vote_down b').html());
    //     }, 2000);
    //   }, 5000
    // ),
		
});
	
	$.fn.extend({    	

  });
})(jQuery);