//= require s3_direct_upload

$(document).ready(function() {
  $("#s3-uploader").S3Uploader({
    remove_completed_progress_bar: false,
    progress_bar_target: $('#uploads_container')
  });

  $('#s3-uploader').bind('s3_upload_failed', function(e, content) {
    return alert(content.filename + ' failed to upload');
  });
});
