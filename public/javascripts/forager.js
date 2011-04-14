$(function() {
  setupIndex();
  setBrowserHeight();
})

function setupIndex() {
  $('#index a').live('click', gotoIndexedLocation);
}

function gotoIndexedLocation() {
  id = this.href.match(/\d+/)[0];
  $('#browser').scrollTo($('#' + id));
  return false;
}

$(window).resize(function() {
  setBrowserHeight();
});

function setBrowserHeight() {
  var availableHeight = $('#page').height();
  $("#browser").height(availableHeight - 213);
}
