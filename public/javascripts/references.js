$(function() {
  setupAddReferenceLink();
  setupDisplays();
  setupForms();
})

/////////////////////////////////////////////////////////////////////////

function setupAddReferenceLink() {
  showAddReferenceLink();
  $('.add_reference_link').click(addReference);
}

function showAddReferenceLink()
{
  if ($('.reference').size() == 0)
    $('.add_reference_link').show();
  else
    hideAddReferenceLink();
}

function hideAddReferenceLink() {
  $('.add_reference_link').hide();
}

/////////////////////////////////////////////////////////////////////////

function setupDisplays()
{
  $('.reference_display').live('click', clickReference);

  $('.reference_display').live('mouseenter',
    function() {
      if (!isEditing())
        $('.reference_action_link', $(this)).show();
    }).live('mouseleave',
    function() {
      if (!isEditing())
        $('.reference_action_link').hide();
    });

  setupActionLinks();
}

function setupActionLinks() {
  if (!usingCucumber)
    $('.reference_action_link').hide();

  $('.reference_action_add').live('click', insertReference);
  $('.reference_action_copy').live('click', copyReference);
  $('.reference_action_delete').live('click', deleteReference);
}

function setupForms() {
  $('.reference_form').hide();
  $('.reference .reference_form form').live('submit', submitReferenceForm);
  $('.reference .reference_form .cancel').live('click', cancelReferenceForm);
  $('.reference .reference_form .delete').live('click', deleteReference);
}

///////////////////////////////////////////////////////////////////////////////////

function clickReference() {
  if (!isEditing())
    showReferenceForm($(this).closest('.reference'), true);
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
  showReferenceForm($newReference, false);
}

function copyReference() {
  $rowToCopyFrom = $(this).closest('tr');
  $newRow = $rowToCopyFrom.clone(true);
  $rowToCopyFrom.after($newRow);
  $newReference = $('.reference', $newRow);
  $newReference.attr("id", "reference_");
  $('form', $newReference).attr("action", "/references");
  $('[name=_method]', $newReference).attr("value", "post");
  showReferenceForm($newReference, true);
}

///////////////////////////////////////////////////////////////////////////////////

function showReferenceForm($reference, focusFirstField)
{
  hideAddReferenceLink();
  $('.reference_display', $reference).hide();
  $('.reference_action_link').hide();

  var $form = $('.reference_form', $reference);
  setWatermarks($form);
  $form.show();

  if (focusFirstField)
    $('#reference_authors', $form).focus();
}

function setWatermarks($form) {
  $('#reference_authors', $form).watermark('Authors');
  $('#reference_year', $form).watermark('Year');
  $('#reference_title', $form).watermark('Title');
  $('#reference_citation', $form).watermark('Citation');
  $('#reference_public_notes', $form).watermark('Published notes');
  $('#reference_editor_notes', $form).watermark("Editor's notes");
  $('#reference_taxonomic_notes', $form).watermark('Taxonomic notes');
  $('#reference_cite_code', $form).watermark('Cite code');
  $('#reference_possess', $form).watermark('Possess');
  $('#reference_date', $form).watermark('Date');
}

function submitReferenceForm() {
  var $spinnerElement = $('button', $(this)).parent();
  $spinnerElement.spinner({img: '/images/spinner.gif'});
  $('input', $spinnerElement).attr('disabled', 'disabled');
  $('button', $spinnerElement).attr('disabled', 'disabled');

  $.post(this.action, $(this).serialize(), null, 'script');

  showAddReferenceLink();

  return false;
}

function cancelReferenceForm() {
  $reference = $(this).closest('.reference');
  if ($reference.attr('id') == 'reference_')
    $reference.closest('tr').remove();
  else {
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

