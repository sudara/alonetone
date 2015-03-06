$(document).ready(function(){
  // resizable textarea for edit page
  $('.post_content textarea').autosize();  
  
  // adjust image margins to fit baseline in posts
  $('.post_content p > img').baseline(27);  
});
