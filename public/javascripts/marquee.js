/*
 * @arthur Scott Johnson 2012
*/ 

var currentPanel = 1;
var totalPanels = 0;
var autoPlay = true;
var timePassed = 0;
var timeToChange = 5;

function autoAdvance(){
  if(window.timePassed == window.timeToChange ){
    window.timePassed =0;
    if(window.currentPanel == window.totalPanels ){
      window.currentPanel = 0;
    }
    if(window.autoPlay == true){
      $('.marquee_nav a.marquee_nav_item:nth-child('+(window.currentPanel + 1)+')').trigger('click');
    }
  }else{
    window.timePassed += 1;
  }
  // /* degug */ $('.autoPlay').html('autoPlay = ' +window.autoPlay);
  // /* degug */ $('.timePassed').html('timePassed = ' +window.timePassed);
};

$(document).ready(function() {
  // /* degug */ $('.autoPlay').html('autoPlay = ' +window.autoPlay);
  // /* degug */ $('.timePassed').html('timePassed = ' +window.timePassed);
  // /* degug */ $('.timeToChange').html('timeToChange = ' +window.timeToChange);
  // /* degug */ $('.currentPanel').html('currentPanel = ' +window.currentPanel);
  
  setInterval(autoAdvance, 1000);
  
  $('.marquee_container').hover(
    function(){
      // roll over
      window.autoPlay = false;
      $(this).removeClass('auto_play');
    },
    function(){
      // roll out
      window.autoPlay = true;
      window.timePassed = 0;
      $(this).addClass('auto_play');
    }
  );
  
  // making one long virtual image [1][2][n]
  $('.marquee_panel_content').each(function(index){
    var panelWidth = $('.marquee_container').width();
    var panelPosition = panelWidth * index;
    var content = $(this) //.html();
    
    $('.marquee_content').append(content);
    $('.marquee_content').css('width', panelWidth + panelPosition );
  });
  
  // add in the nav elements
  $('.marquee_panels .marquee_panel').each(function(index){
    $('.marquee_nav_buttons').append('<a class="marquee_nav_item"></a>');
    window.totalPanels = index + 1;
    // /* degug */ $('.totalPanels').html('totalPanels = ' +window.totalPanels);
  });
  
  // manage the click event for the nav elements
  $('.marquee_nav a.marquee_nav_item').click(function(){
    $('.marquee_nav a.marquee_nav_item').removeClass('selected');
    $(this).addClass('selected');
    
    // calculate where to put the virtual panel [1][2][n] so the correct panel is in the window
    var navClicked = $(this).index();
    var marqueeWidth = $('.marquee_container').width();
    var distanceToMove = marqueeWidth*(-1);
    var newPanelPosition = navClicked * distanceToMove + 'px'
    window.currentPanel = navClicked +1;
    // /* degug */ $('.currentPanel').html('currentPanel = ' +window.currentPanel);
    
    // animate and display the correct panel
    $('.marquee_content').animate({left:newPanelPosition}, 1000);
    
    // set READ link to current article
    var currentPanel = $('.marquee_panel_content').get(navClicked);
    var navLink = $(currentPanel).find('.data').attr('href');
    $('a#news_current_nav_link').attr('href', navLink);
    
    
  });
  
  initializeMarquee();
});

// have the marquee start out with no images, then have the first one fade in and be selected
function initializeMarquee(){
 $('.marquee_caption_content').html(
   $('.marquee_panels .marquee_panel:first .marquee_panel_caption').html()
  );
  $('.marquee_nav a.marquee_nav_item:first').addClass('selected');
  $('.marquee_content').fadeIn(500); 
  setLink(); 
}

// get the caption to animate and show on the inital update
function setLink(){
  // set READ link to first article
  var currentPanel = $('.marquee_panel_content:first');
  var navLink = $(currentPanel).find('.data').attr('href');
  $('a#news_current_nav_link').attr('href', navLink);
  
}


