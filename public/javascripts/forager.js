$(function() {
  setupIndex();
  setupBrowser();
  setBrowserHeight();
  setBrowserWidth();
})

function setupIndex() {
  $('#index a').live('click', gotoIndexedLocation);
}

function gotoIndexedLocation() {
  id = this.href.match(/\d+/)[0];
  $('#browser').scrollTo($('#' + id));
  return false;
}

function setupBrowser() {
  setBrowserHeight();
  setBrowserWidth();
  $(window).resize(function() {
    setBrowserHeight();
    setBrowserWidth();
  });
}

function setBrowserHeight() {
  var availableHeight = $('#page').height();
  $("#browser").height(availableHeight - 213);
}

function setBrowserWidth() {
  $("#browser").width($('#page').width() - $('#index').width() - 25);
}
