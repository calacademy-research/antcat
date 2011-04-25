$(function() {
  setupViewSelector();
});

function setupViewSelector() {
  $(".taxatry_view_selector").buttonset();
  $(".taxatry_view_selector input").click(function() {
    document.location.href = $(this).attr('path');
  });
}
