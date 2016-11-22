is_selector_valid = (selector) ->
  try
    $(selector) # throws 'Syntax error, unrecognized expression' in Chrome
    true
  catch
    false

# JavaScript snippet to be pasted into the browser by editors, looks something like this:
# testTooltipSelector('label[for=\'reference_title\']', 'A title');
generate_test_string = ->
  selector = $('[name="tooltip[selector]"]').val()
  # "Double escaping" single quotes, because the selector string may contain either
  # single, double quotes, or both at the same time.
  selector = selector.replace /'/g, "\\'"
  text     = $('[name="tooltip[text]"]').val()

  "testTooltipSelector('#{selector}', '#{text}');"

$ ->
  $('#test_selector_button').click ->
    selector = $('[name="tooltip[selector]"]').val()
    selector_valid = is_selector_valid selector

    notice = $('p#test_selector_notice')
    if selector_valid
      test_string = generate_test_string()
      notice.text """It looks like the syntax of the selector is valid, but that does not mean it
        will work as intended. To test is, go to the page where you want to add the tooltip, open
        your browser's JavaScript Console (in Chrome: Ctrl+Shift+J on Windows, Cmd+Opt+J on Mac),
        and paste this snippet into the console (note that the tooltip link is not supposed to
        work, only the selector and text are tested):"""
      $('pre#test_selector_snippet').text test_string
    else
      notice.text "Syntax error, unrecognized expression"
