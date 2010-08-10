$(function() {
  spaceOutImages();

  $('.reference_form').hide();

  $('.reference_link').live('click', function() {
    id = $(this).closest('.reference').attr('id');
    id = /\d+$/.exec(id)[0];
    $('#reference_display_' + id).hide();
    $('#flash_notice').remove();
    $('.reference_form').hide();
    $('#reference_form_' + id).show();
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
    $.post(this.action, $(this).serialize(), null, 'script');
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

