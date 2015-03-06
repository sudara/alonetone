$(function() {
  $('input[type=file].mp3_upload').each(function() {
    var field = $(this);
    var container = field.parent();
    var results = container.find('.supporting_file_list');
    field.fileupload({
      dataType: 'json',
      //acceptFileTypes: /(\.|\/)(mp3)$/i,
      add: function(e, data) {
        var result = $('<li class="file fa fa-li">');
        result.append($('<div class="name">').text(data.files[0].name));
        result.append($('<div class="status">'));
        results.append(result);

        data.formData = null;
        data.context = result;
        data.submit();
      },

      done: function(e, data) {
        data.context.find('.status').html(data.result.status);
        data.context.removeClass('complete');
        if (!data.result.success){
          data.context.addClass('fa-times');
        }
        else{
          data.context.addClass('fa-check-square');
        }
      },

      progress: function(e, data) {
        var pct = parseInt(data.loaded / data.total * 100, 10);
        if (pct == 100) {
          data.context && data.context.find('.status').text('Processing...');
        } else {
          data.context && data.context.find('.status').text(pct+'%');
        }
      }
    });
  });
});
