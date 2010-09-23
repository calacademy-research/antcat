$(function() {
  if (loggedIn) {
    setupAddReferenceLink();
    setupDisplays();
    setupForms();
  }
  //addReference();
  //$('#reference_ .authors input').focus();
})

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
  $('.reference_display').live('click', editReference);

  $('.reference_display').addClass('editable');

  $('.reference').live('mouseenter',
    function() {
      if (!isEditing())
        $('.icon', $(this)).show();
    }).live('mouseleave',
    function() {
      if (!isEditing())
        $('.icon').hide();
    });

  $('.icon').live('mouseenter',
    function() {
      $(this).addClass('highlighted');
    }).live('mouseleave',
    function() {
      $(this).removeClass('highlighted');
    });

  setupIcons();
}

function setupIcons() {
  if (!usingCucumber)
    $('.icon').hide();
  else
    $('.icon').show();

  $('.icon.edit').live('click', editReference);
  $('.icon.add').live('click', insertReference);
  $('.icon.copy').live('click', copyReference);
  $('.icon.delete').live('click', deleteReference);
}

function setupForms() {
  $('.reference_form').hide();
  $('.reference_form form').live('submit', submitReferenceForm);
  $('.reference_form .cancel').live('click', cancelReferenceForm);
  $('.reference_form .delete').live('click', deleteReference);
  $('.tabs').tabs();
}

///////////////////////////////////////////////////////////////////////////////////

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
}

function insertReference() {
  addOrInsertReferenceForm($(this).closest('.reference'));
}

function addOrInsertReferenceForm($reference) {
  $referenceTemplateRow = $('.reference_template_row');
  $newReferenceRow = $referenceTemplateRow.clone(true);
  $newReferenceRow.removeClass('reference_template_row');
  $('.reference_template', $newReferenceRow).removeClass('reference_template').addClass('reference');

  if ($reference == null)
    $('.references').prepend($newReferenceRow);
  else
    $reference.closest('tr').after($newReferenceRow);

  $newReference = $('.reference', $newReferenceRow);
  showReferenceForm($newReference);
}

function copyReference() {
  $rowToCopyFrom = $(this).closest('tr');
  $newRow = $rowToCopyFrom.clone(true);
  $rowToCopyFrom.after($newRow);
  $newReference = $('.reference', $newRow);
  $newReference.attr("id", "reference_");
  $('form', $newReference).attr("action", "/references");
  $('[name=_method]', $newReference).attr("value", "post");
  showReferenceForm($newReference, {focusFirstField: true});
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
  $form.show();

  if (options.focusFirstField)
    $('#reference_authors', $form).focus();

  if (!options.showDeleteButton)
    $('.delete', $form).hide();

  setupAuthorAutocomplete($reference);
}

function setWatermarks($form) {
  $('#reference_year', $form).watermark('Year');
  $('#reference_title', $form).watermark('Title');
  $('#reference_public_notes', $form).watermark('Published notes');
  $('#reference_editor_notes', $form).watermark("Editor's notes");
  $('#reference_taxonomic_notes', $form).watermark('Taxonomic notes');
  $('#reference_cite_code', $form).watermark('Cite code');
  $('#reference_possess', $form).watermark('Possess');
  $('#reference_date', $form).watermark('Date');
}

function submitReferenceForm() {
  var $spinnerElement = $('button', $(this)).parent();
  $spinnerElement.spinner({img: '/stylesheets/ext/jquery-ui/images/ui-anim_basic_16x16.gif'});
  $('input', $spinnerElement).attr('disabled', 'disabled');
  $('button', $spinnerElement).attr('disabled', 'disabled');

  var selectedTab = $(this).closest('.reference .ui-tabs-selected a').text();
  $.post(this.action, $(this).serialize(), updateReference, 'json');

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

