document.documentElement.className = 'js'; // FOUC fix

$(function() {
  setupLogin();
  spaceOutImages();
  $("input[type=text]:first").focus()
})

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
  var availableWidth = $('#images').width();
  var marginInBetween = (availableWidth - totalImageWidth) / (imageCount - 1);
  $(".spacer").width(marginInBetween);
}
