$(document).ready(function(){
  $('.single-item').slick({
    lazyLoad: 'on-demand', 
    arrows: true,
    dots: true
  });
  // overrides the slick styling to center book images
  $('img.book-image').css('display', 'inline');
  $('img.book-image').css('margin-bottom', '1em')
});
