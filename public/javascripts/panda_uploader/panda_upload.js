var upl=panda.uploader.init({
   'buttonId': 'browse-files',
   'progressBarId': "progress-bar",
   'fileDropId': "file-drop",
   
   'onQueue': function(files) {
    alert("alert "+ AUTH_TOKEN);
    $.each(files, function(i, file) {
    upl.setPayload(file, {'authenticity_token': AUTH_TOKEN_PANDA});
   })
  },   

   'onProgress': function(file, percent) {
    console.log("progress", percent, "%");
   },

    'onSuccess': function(file, data) {
      $("#new_video")
      .find("[name=panda_video_id]")
      .val(data.id)
      .end()
      .submit();
   },

   'onComplete': function(){
      $("#new_video").submit();
    },

  'onError': function(file, message) {
   console.log("error", message);
  }

  });
