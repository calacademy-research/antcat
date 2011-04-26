$(function() {
  setupPage();
  setupIndex();
  setupBrowser();
})

function setupPage() {
  setPageHeight();
  $(window).resize(function() {
    setPageHeight();
  });
}

function setPageHeight() {
  height = $('#page').height() - $('#site_header').height() - $('#page_header').height() - $('#page_notice').height() - $('#page_alert').height() - $('#search_results').height() - $('#taxon_key').height() - $('#site_footer').height() - 4;
  $("#browser").height(height);
  headerHeight = $("#browser .header").height();
  // no idea why this is necessary
  if (headerHeight > 0)
    headerHeight += 16;
  $("#browser .contents").height(height - headerHeight);
  $("#index").height(height);
}

function setupIndex() {
  $('#index a').live('click', function() {
    id = this.href.match(/\d+/)[0];
    selectBrowserItem(id);
    return false;
  });
}

function setupBrowser() {
  setBrowserWidth();
  $(window).resize(function() {
    setBrowserWidth();
  });
  selectBrowserItem(selectedBrowserTaxonID);
}

function selectBrowserItem(id) {
  if (!id) return;
  $('#browser .contents').scrollTo($('#' + id));
  $('#' + id).effect("highlight", {}, 3000)
}

function setBrowserWidth() {
  $("#browser").width($('#page_contents').width() - $('#index').width() - 30);
}
