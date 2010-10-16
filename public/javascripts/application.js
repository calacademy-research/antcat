$(function() {
  spaceOutImages();
  $("input[type=text]:first").focus()
})

$(window).resize(function() {
  spaceOutImages();
});

function spaceOutImages() {
  var totalImageWidth = 271;
  var imageCount = 4;
  var availableWidth = $('#images').width();
  var marginInBetween = (availableWidth - totalImageWidth) / (imageCount - 1);
  $(".spacer").width(marginInBetween);
}
