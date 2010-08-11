$(function() {
  spaceOutImages();

  $('.reference_form').hide();

//$('.reference_display').first().hide();
//$('.reference_form').first().show();

  $('.reference_link').live('click', function() {
    if ($('.reference_form').is(':visible'))
      return false;
    id = $(this).closest('.reference').attr('id');
    id = /\d+$/.exec(id)[0];
    $('#reference_display_' + id).hide();
    $('#flash_notice').remove();
    $('.reference_form').hide();

    var $form = $('#reference_form_' + id);
    $form.show();
    $('#reference_authors', $form).watermark('Authors');
    $('#reference_authors', $form).focus();
    $('#reference_year', $form).watermark('Year');
    $('#reference_title', $form).watermark('Title');
    $('#reference_citation', $form).watermark('Citation');
    $('#reference_public_notes', $form).watermark('Published notes');
    $('#reference_private_notes', $form).watermark('Private notes');
    $('#reference_taxonomic_notes', $form).watermark('Taxonomic notes');

    return false;
  });

  $('.reference_form .cancel').live('click', function(event) {
    href = $(this).closest('form').attr('action');
    id = /\d+$/.exec(href)[0];
    $('#reference_display_' + id).show();
    $('#reference_form_' + id).hide();

    return false;
  });

  $('.reference_form form').live('submit', function(event) {
    var $spinnerElement = $('button', $(this)).parent();
    $spinnerElement.spinner({img: '/images/spinner.gif'});
    $('input', $spinnerElement).attr('disabled', 'disabled');
    $('button', $spinnerElement).attr('disabled', 'disabled');

    $.post(this.action, $(this).serialize(), {}, 'script');

    return false;
  });
})

$(window).resize(function() {
  spaceOutImages();
});

function spaceOutImages() {
  var totalImageWidth = 271;
  var imageCount = 4;
  var availableWidth = $('#images').width();
  var marginInBetween = (availableWidth - totalImageWidth) / (imageCount - 1);
  $(".spacer").width(marginInBetween);
}

