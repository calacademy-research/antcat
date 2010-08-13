$(function() {
  $('.reference_form').hide();

//$('.reference_display').first().hide();
//$('.reference_form').first().show();

  $('.reference .reference_link').live('click', clickReference);
  $('.reference .reference_form form').live('submit', submitReferenceForm);
  $('.reference .reference_form .cancel').live('click', cancelReferenceForm);
  $('.add_reference_link').click(showAddReferenceForm);

//insertReferenceForm();
})

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
  if (!$('.reference_form').is(':visible'))
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
