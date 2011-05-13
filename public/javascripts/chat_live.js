(function($) {  // $ = jQuery within this block
  
	$(document).ready(function() {
	  //
	  // IN CHAT FUNCTIONS
    //

    // Scrolling on page load
    // $.scrollTo('div#present_container'),
    //$('div#present_container > div:first').scrollTo($('table#present_discussion').height()),
    
    
    


    // TODO: Display accordion on present conversation
    // Showing present conversation on page load
    $('div.present').show(),
    
    // Setup topic polling every 10 seconds
    setInterval(function() { Topic.poll(); }, 30000), // 10000
     
    // Setup active topic polling every 3 seconds
    setInterval(function() { ActiveTopic.poll(); }, 8000), // 3000
    
    // Setup chat polling every 3 seconds
    setInterval(function() { Post.poll(); PostQueue.dequeue(); }, 5000), // 3000
    
    // Setup participant polling every 8 seconds
    setInterval(function() { Chat.poll_participants(); }, 60000), // 8000
    
    // Load the posts from scripts varaible
    ActiveTopic.add_posts_from_json(present_discussion_posts, {delay_scroll:true}),
    
    // Load the question bin
    Topic.fetch_queued(),
    
    // If I'm a host, refresh the question bin
    Topic.host_vote_polling(chat_host_present),
    
    // Choosing a question to discuss
    $('a.discuss_now').live('click', function(event) {      
      Topic.discuss(this);
      
      return false;
    }),
    
    // Focus on the text area
    Post.textarea().focus();

    // Submit on Return. Newline on Shift+Return
    Post.textarea().live('keydown', function(e) {
        if(e.which == 13 && !e.shiftKey) {
            Post.form().submit();
        }
    });

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