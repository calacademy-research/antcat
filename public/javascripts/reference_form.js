$(function() {
  $('.reference_form').hide();

  $('.reference .reference_display').live('click', clickReference);
  $('.reference .reference_form form').live('submit', submitReferenceForm);
  $('.reference .reference_form .cancel').live('click', cancelReferenceForm);
  $('.add_reference_link').click(showAddReferenceForm);

  setupDelete();
})

function isEditing() {
  return $('.reference_form').is(':visible');
}

function setupDelete() {
  $('.reference_display').live('mouseenter',
    function() {
      if (!isEditing())
        $('.reference_action_link', $(this)).removeClass('hidden');
    }).live('mouseleave',
    function() {
      if (!isEditing())
        $('.reference_action_link').addClass('hidden');
    });

  $('.reference_action_link').live('click', deleteReference);
  $('.reference .reference_form .delete').live('click', deleteReference);
}

function deleteReference() {
  $reference = $(this).closest('.reference');
  $reference.addClass('about_to_be_deleted');
  if (confirm('Do you want to delete this reference?')) {
    $.post($reference.find('form').attr('action'), {'_method': 'delete'})
    $reference.closest('tr').remove();
  } else
    $reference.removeClass('about_to_be_deleted');
  return false;
}

function showAddReferenceForm() {
  $('.add_reference_link').hide();
  insertReferenceForm();
}

function insertReferenceForm() {
  $referenceTemplateRow = $('.reference_template_row');
  $newReferenceRow = $referenceTemplateRow.clone(true);
  $newReferenceRow.removeClass('reference_template_row');
  $('.reference_template', $newReferenceRow).removeClass('reference_template').addClass('reference');
  $('.references').prepend($newReferenceRow);
  $newReference = $('.reference', $newReferenceRow);
  showReferenceForm($newReference, false);
}

function clickReference() {
  if (!isEditing())
    showReferenceForm($(this).closest('.reference'), true);
  return false;
}

function showReferenceForm($reference, focusFirstField)
{
  $('.reference_display', $reference).hide();
  $('.add_reference_link').hide();

  var $form = $('.reference_form', $reference);
  setWatermarks($form);
  $form.show();

  if (focusFirstField)
    $('#reference_authors', $form).focus();
}

function submitReferenceForm() {
  var $spinnerElement = $('button', $(this)).parent();
  $spinnerElement.spinner({img: '/images/spinner.gif'});
  $('input', $spinnerElement).attr('disabled', 'disabled');
  $('button', $spinnerElement).attr('disabled', 'disabled');

  $.post(this.action, $(this).serialize(), null, 'script');

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
  $('.add_reference_link').show();

  return false;
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
