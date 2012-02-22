$(function() {
  setupViewSelector();
});

function setupViewSelector() {
  $(".catalog_view_selector").buttonset();
  $(".catalog_view_selector input").click(function() {
    document.location.href = $(this).attr('path');
  });
}
