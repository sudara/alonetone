// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('.edit_playlist').each(function() {
    var form = $(this);
    var posts = form.find('ol');
    var sources = form.find('ul');

    sources.on('click', 'li a[data-method=post]', function(e) {
      var post = $(this).parents('li');
      var post_id = post.data('post_id');
      if (e.which == 1 && !e.altKey && !e.ctrlKey && !e.metaKey) {
        e.preventDefault();

        $.ajax({
          method: 'post',
          url: form.attr('action')+'/posts?post_id='+post_id,
          success: function() {
            posts.append(post.detach());
          }
        });
      }
    });

    posts.on('click', 'li a[data-method=delete]', function(e) {
      var post = $(this).parents('li');
      var post_id = post.data('post_id');
      if (e.which == 1 && !e.altKey && !e.ctrlKey && !e.metaKey) {
        e.preventDefault();

        $.ajax({
          method: 'delete',
          url: form.attr('action')+'/posts?post_id='+post_id,
          success: function() {
            sources.append(post.detach());
          }
        });
      }
    });

    $(this).find('ol').sortable({
      stop: function(e, ui) {
        var posts = form.find('ol').
          sortable('toArray', { attribute: 'data-post_id' }).
          filter(function(post_id) { return post_id.length });
        $.ajax({
          method: 'put',
          url: form.attr('action')+'/posts',
          data: { post_ids: posts }
        });
      }
    });
  });
});
