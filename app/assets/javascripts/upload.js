//= require s3_direct_upload

$(document).ready(function() {
  var maxSize = $('#s3-uploader').data('max-file-size');
  var maxSizeH = $('#s3-uploader').data('max-file-size-human');
  var contentType = ($('#s3-uploader').data('expected-content-type') || '').split(/\s+/);

  var addContentTypeError = function(file) {
    var template = $($.trim(tmpl("template-upload", file)));
    template.addClass('error');
    template.find('ul.messages').append(
      $('<li>').text("It doesn't look like this is a valid zip file. Could you double check?")
    );
    template.find('.progress .bar').css('width', '100%');
    $('#uploads_container').append(template);
  };

  var addFileSizeError = function(file) {
    var template = $($.trim(tmpl("template-upload", file)));
    template.addClass('error');
    template.find('ul.messages').append(
      $('<li>').text("This file is too big. The maximum size is " + maxSizeH)
    );
    template.find('.progress .bar').css('width', '100%');
    $('#uploads_container').append(template);
  };

  $("#s3-uploader").S3Uploader({
    remove_completed_progress_bar: false,
    progress_bar_target: $('#uploads_container'),
    before_add: function(file) {
      if (contentType.indexOf(file.type) == -1) {
        addContentTypeError(file);
        return false;
      }
      if (maxSize < file.size) {
        addFileSizeError(file);
        return false;
      }
      return true;
    }
  });

  $('#s3-uploader').bind('s3_upload_failed', function(e, content) {
    $('#upload_' + content.unique_id).addClass('error');
    $('#upload_' + content.unique_id + ' ul.messages').append(
      $('<li>').text("There was an error uploading this file. " +
                     "Please ensure it is a zip file and less than " + maxSizeH +
                     ", and try again.")
    );
    return alert(content.filename + ' failed to upload');
  });
});
