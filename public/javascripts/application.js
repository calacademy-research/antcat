$(function() {
  spaceOutImages();

  $("#journal").autocomplete({source: "/journals", minLength: 3});

  $("#start_year").keyup(function(event) {
    if (event.which != 9)
      $("#end_year").val($(this).val());
  });
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
