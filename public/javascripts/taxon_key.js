$(function() {spaceOutTaxonKeyItems();});
$(window).resize(function() {spaceOutTaxonKeyItems();});

function spaceOutTaxonKeyItems() {
  var totalItemWidth = 0;
  var itemCount = 0;
  $(".taxon_key_item").each(
    function() {
      totalItemWidth += $(this).width();
      ++itemCount;
    }
  );
  var availableWidth = $('#taxon_key').width();
  var marginInBetween = (availableWidth - totalItemWidth) / (itemCount - 1);
  $("#taxon_key .spacer").width(marginInBetween);
}

