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
  height = $('#page').height() - 213
  $("#browser").height(height);
  $("#index").height(height);
}

function setupIndex() {
  $('#index a').live('click', function() {
    $('#index a').removeClass('selected');
    $(this).addClass('selected');
    id = this.href.match(/\d+/)[0];
    $('#browser').scrollTo($('#' + id));
    return false;
  });
}

function setupBrowser() {
  setBrowserWidth();
  $(window).resize(function() {
    setBrowserWidth();
  });
}

function setBrowserWidth() {
  $("#browser").width($('#page_contents').width() - $('#index').width() - 30);
}
