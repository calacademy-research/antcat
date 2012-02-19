$(function() {
  setupPage();
  setupHelp();
  setupIcons();
  setupReferenceKeys();
})

////////////////////////////////////////
function setupPage() {
  setDimensions();
  $(window).resize(function() {
    setDimensions();
  });
}

function setDimensions() {
  setHeight();
  setWidth();
}

function setHeight() {
  height = $('#page').height()
         - $('#site_header').height()
         - $('#page_header').height() - 2
         - $('#page_notice').height()
         - $('#page_alert').height()
         - $('#search_results').height() - 3 - 2 - 2 -
         $('#taxon_key').height() - 2 -
         $('#site_footer').height() - 8;
  $("#catalog").height(height);
  $("#catalog .index").height(height - $("#catalog .content").height());
}

function setWidth() {
  $("#catalog .content").width($('#page').width());
}

////////////////////////////////////////
function setupReferenceKeys() {
  $('.reference_key').live('click', expandReferenceKey);
  $('.reference_key_expansion_text').live('click', expandReferenceKey);
}

function expandReferenceKey() {
  $('.reference_key',           $(this).closest('.reference_key_and_expansion')).toggle();
  $('.reference_key_expansion', $(this).closest('.reference_key_and_expansion')).toggle();
}

////////////////////////////////////////
function setupHelp() {
  setupQtip('.document_link', "Click to download and view the document");
  setupQtip('.goto_reference_link', "Click to view/edit this reference on its own page");
}

////////////////////////////////////////
function isEditing() {
  return false;
}

function setupIcons() {
  setupIconVisibility();
  if (user_can_edit) {
    setupIconHighlighting();
    setupIconClickHandlers();
  }
}

function setupIconVisibility() {
  if (!testing || !user_can_edit)
    $('.icon').hide();

  if (!user_can_edit)
    return

  $('.history_item').live('mouseenter',
    function() {
      if (!isEditing())
        $('.icon', $(this)).show();
    }).live('mouseleave',
    function() {
      $('.icon').hide();
    });
}

function setupIconHighlighting() {
  $('.icon img').live('mouseenter',
    function() {
      this.src = this.src.replace('off', 'on');
    }).live('mouseleave',
    function() {
      this.src = this.src.replace('on', 'off');
    });
}

function setupIconClickHandlers() {
  $('.icon.edit').live('click', editHistoryItem);
}

function editHistoryItem() {
}
