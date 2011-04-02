document.documentElement.className = 'js'; // FOUC fix

function toggleDivs(show,hide) {
    var toShow = document.getElementById(show);
    var toHide = document.getElementById(hide);
    if (toShow.style.display == "") {
        toShow.style.display = "none";
        toHide.style.display = "";
    } else {
        toShow.style.display = "";
        toHide.style.display = "none";
    }
}

$(function() {
  spaceOutImages();
  $("input[type=text]:first").focus()
})

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
