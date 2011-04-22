document.documentElement.className = 'js'; // FOUC fix

preloadImages();

$(function() {
  setupLogin();
  spaceOutImages();
  $("input[type=text]:visible:first").focus();
})

function preloadImages() {
  var images = new Array('/images/header_bg.png', '/images/antcat_logo.png', '/images/site_header_ant_5.png')
  for (var i = 0; i < images.length; i++) {
    var image = new Image();
    image.src = images[i];
  }
}

function setupLogin() {
  $('#login .form').hide();
  $('#login a.link').click(function() {
    $('#login div').toggle();
  });
}

$(window).resize(function() {
  spaceOutImages();
});

function spaceOutImages() {
  var totalImageWidth = 379 + 154;
  var imageCount = 6;
  var availableWidth = $('#site_footer .images').width();
  var marginInBetween = (availableWidth - totalImageWidth) / (imageCount - 1);
  $(".spacer").width(marginInBetween);
}
