$(function() {
    observeEvents();
});

function observeEvents(){
    var content = $('#loginFormContent');
    var form = $('#loginForm');
    $('#login_submit').click(function(e){
        e.preventDefault();
        checkLogin(content, form)
    })
}

function checkLogin(content, form){
    $.ajax({
      type: 'POST',
      url: '/users',
      data: form.serialize(),
      success: function(e){
          loadAjaxContent(e.continue_to, content);
      }
    });
}

function loadAjaxContent(url, content){
    $.ajax({
      type: 'GET',
      url: url,
      success: function(e){
          content.html(e);
      }
    });
}