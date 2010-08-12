$(function() {
  $('.reference_form').hide();

//$('.reference_display').first().hide();
//$('.reference_form').first().show();

  $('.reference_link').live('click', showReferenceForm);
  $('.reference_form form').live('submit', submitReferenceForm);
  $('.reference_form .cancel').live('click', cancelReferenceForm);
})

function showReferenceForm() {
  if ($('.reference_form').is(':visible'))
    return false;

  $reference = $(this).closest('.reference')

  $('.reference_display', $reference).hide();

  var $form = $('.reference_form', $reference);
  setWatermarks($form);
  $form.show();

  $('#reference_authors', $form).focus();

  return false;
}

function submitReferenceForm() {
  var $spinnerElement = $('button', $(this)).parent();
  $spinnerElement.spinner({img: '/images/spinner.gif'});
  $('input', $spinnerElement).attr('disabled', 'disabled');
  $('button', $spinnerElement).attr('disabled', 'disabled');

  $.post(this.action, $(this).serialize(), {}, 'script');

  return false;
}

function cancelReferenceForm() {
  $reference = $(this).closest('.reference')
  $('.reference_display', $reference).show();
  $('.reference_form', $reference).hide();

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
