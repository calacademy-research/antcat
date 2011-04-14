$(function() {
  setupIndex();
})

function setupIndex() {
  $('#index a').live('click', gotoIndexedLocation);
}

function gotoIndexedLocation() {
  id = this.href.match(/\d+/)[0];
  $('#browser').scrollTo($('#' + id));
  return false;
}
