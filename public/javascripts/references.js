$(function() {
  setupSearch();
  if (loggedIn) {
    setupAddReferenceLink();
    setupDisplays();
    setupForms();
  }
  //if (!usingCucumber) {
    //addReference();
    //$('#reference_ #reference_authors_string').focus();
  //}
})

function setupSearch() {
  setupSearchAutocomplete();
  $("#start_year").keyup(function(event) {
    if (event.which != 9)
      $("#end_year").val($(this).val());
  });
}

/////////////////////////////////////////////////////////////////////////

function setupAddReferenceLink() {
  showAddReferenceLink();
  $('.add_reference_link').click(addReference);
}

function showAddReferenceLink() {
  if ($('.reference').size() == 0)
    $('.add_reference_link').show();
  else
    hideAddReferenceLink();
}

function hideAddReferenceLink() {
  $('.add_reference_link').hide();
}

/////////////////////////////////////////////////////////////////////////

function setupDisplays() {
  $('.source_link').live('click', viewSource);
  $('.reference_display').live('click', editReference);
  $('.reference_display').addClass('editable');

  setupIcons();
}

function setupIcons() {
  if (!usingCucumber)
    $('.icon').hide();
  else
    $('.icon').show();

  $('.reference').live('mouseenter',
    function() {
      if (!isEditing())
        $('.icon', $(this)).show();
    }).live('mouseleave',
    function() {
      $('.icon').hide();
    });

  $('.icon img').live('mouseenter',
    function() {
      this.src = this.src.replace('off', 'on');
    }).live('mouseleave',
    function() {
      this.src = this.src.replace('on', 'off');
    });

  $('.icon.edit').live('click', editReference);
  $('.icon.add').live('click', insertReference);
  $('.icon.copy').live('click', copyReference);
  $('.icon.delete').live('click', deleteReference);
}

function setupForms() {
  $('.reference_form').hide();
  $('.reference_form .submit').live('click', submitReferenceForm);
  $('.reference_form .cancel').live('click', cancelReferenceForm);
  $('.reference_form .delete').live('click', deleteReference);
}

///////////////////////////////////////////////////////////////////////////////////

function viewSource() {
  window.location = this.href;
  return false;
}

function editReference() {
  if (isEditing())
    return false;

  $reference = $(this).closest('.reference');
  saveReference($reference);
  showReferenceForm($reference, {focusFirstField: true, showDeleteButton: true});
  return false;
}

function deleteReference() {
  $reference = $(this).closest('.reference');
  $reference.addClass('about_to_be_deleted');
  if (confirm('Do you want to delete this reference?')) {
    $.post($reference.find('form').attr('action'), {'_method': 'delete'})
    $reference.closest('tr').remove();
  } else
    $reference.removeClass('about_to_be_deleted');

  showAddReferenceLink();
  return false;
}

function addReference() {
  addOrInsertReferenceForm(null);
  return false;
}

function insertReference() {
  addOrInsertReferenceForm($(this).closest('.reference'));
  return false
}

function copyReference() {
  $rowToCopyFrom = $(this).closest('tr.reference_row');
  $newRow = $rowToCopyFrom.clone(true);
  $rowToCopyFrom.after($newRow);
  $newReference = $('.reference', $newRow);
  $newReference.attr("id", "reference_");
  $('form', $newReference).attr("action", "/references");
  $('[name=_method]', $newReference).attr("value", "post");
  showReferenceForm($newReference, {focusFirstField: true});
  return false;
}

function addOrInsertReferenceForm($reference) {
  $referenceTemplateRow = $('.reference_template_row');
  $newReferenceRow = $referenceTemplateRow.clone(true);
  $newReferenceRow.removeClass('reference_template_row').addClass('reference_row');
  $('.reference_template', $newReferenceRow).removeClass('reference_template').addClass('reference');

  if ($reference == null)
    $('.references').prepend($newReferenceRow);
  else
    $reference.closest('tr').after($newReferenceRow);

  $newReference = $('.reference', $newReferenceRow);
  showReferenceForm($newReference);
}

///////////////////////////////////////////////////////////////////////////////////

function saveReference($reference) {
  var $savedReference = $reference.clone(true);
  $savedReference.attr('id', 'saved_reference');
  $('.references').append($savedReference);
  $savedReference.hide();
}

function restoreReference($reference) {
  var id = $reference.attr('id');
  $savedReference = $('#saved_reference');
  $reference.replaceWith($savedReference);
  $savedReference.attr('id', id);
  $savedReference.show();
}

function showReferenceForm($reference, options) {
  if (!options)
    options = {}

  hideAddReferenceLink();
  $('.reference_display', $reference).hide();
  $('.icon').hide();

  var $form = $('.reference_form', $reference);
  setWatermarks($form);
  setTabs($reference);
  $form.show();

  if (options.focusFirstField)
    $('#reference_authors', $form).focus();

  if (!options.showDeleteButton)
    $('.delete', $form).hide();

  setupAuthorAutocomplete($reference);
  setupJournalAutocomplete($reference);
  setupPublisherAutocomplete($reference);
}

function setWatermarks($form) {
  $('#reference_authors_string', $form).watermark('Authors');
  $('#reference_citation_year', $form).watermark('Year');
  $('#reference_title', $form).watermark('Title');

  $('#journal_title', $form).watermark('Journal');
  $('#reference_series_volume_issue', $form).watermark('Series, volume, issue');
  $('#article_pagination', $form).watermark('Page');

  $('#publisher_string', $form).watermark('Place: Publisher');
  $('#book_pagination', $form).watermark('Pages');

  $('#reference_citation', $form).watermark('Citation');

  $('#reference_public_notes', $form).watermark('Published notes');
  $('#reference_editor_notes', $form).watermark("Editor's notes");
  $('#reference_taxonomic_notes', $form).watermark('Taxonomic notes');
  $('#reference_cite_code', $form).watermark('Cite code');
  $('#reference_possess', $form).watermark('Possess');
  $('#reference_date', $form).watermark('Date');
}

function setTabs($reference) {
  var id = $reference.attr('id');
  var selected_tab = $('.selected_tab', $reference).val();

  $('.tabs .article-tab', $reference).attr('href', '#reference_article' + id);
  $('.tabs .article-tab-section', $reference).attr('id', 'reference_article' + id);

  $('.tabs .book-tab', $reference).attr('href', '#reference_book' + id);
  $('.tabs .book-tab-section', $reference).attr('id', 'reference_book' + id);

  $('.tabs .other-tab', $reference).attr('href', '#reference_other' + id);
  $('.tabs .other-tab-section', $reference).attr('id', 'reference_other' + id);

  $('.tabs', $reference).tabs({selected: selected_tab});
}

function submitReferenceForm() {
  var $thisForm = $(this).closest('form');
  var $spinnerElement = $('button', $thisForm).parent();
  $spinnerElement.spinner({position: 'left', img: '/stylesheets/ext/jquery-ui/images/ui-anim_basic_16x16.gif'});
  $('input', $spinnerElement).attr('disabled', 'disabled');
  $('button', $spinnerElement).attr('disabled', 'disabled');

  var selectedTab = $.trim($('.ui-tabs-selected', $thisForm).text());
  $.post($thisForm.attr('action'), $thisForm.serialize() + '&selected_tab=' + selectedTab, updateReference, 'json');

  showAddReferenceLink();

  return false;
}

function updateReference(data) {
  var $reference = $('#reference_' + (data.isNew ? '' : data.id));

  var $form = $('.reference_form', $reference);

  var $spinnerElement = $('button', $form).parent();
  $('input', $spinnerElement).attr('disabled', '');
  $('button', $spinnerElement).attr('disabled', '');
  $spinnerElement.spinner('remove');

  $reference.parent().html(data.content);

  if (!data.success) {
    $reference = $('#reference_' + (data.isNew ? '' : data.id));
    showReferenceForm($reference);
    return;
  }

  $reference = $('#reference_' + data.id);
  $('.reference_form', $reference).hide();

  var $display = $('.reference_display', $reference);
  $display.show();
  $display.addClass('editable');
  $display.effect("highlight", {}, 3000);
}

function cancelReferenceForm() {
  $reference = $(this).closest('.reference');
  if ($reference.attr('id') == 'reference_')
    $reference.closest('tr').remove();
  else {
    restoreReference($reference);
    $('.reference_display', $reference).show();
    $('.reference_form', $reference).hide();
  }

  showAddReferenceLink();

  return false;
}

////////////////////////////////////////////////////////////////////////////////

function isEditing() {
  return $('.reference_form').is(':visible');
}

