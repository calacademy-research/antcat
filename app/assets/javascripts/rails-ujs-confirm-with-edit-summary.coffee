# Like https://github.com/rails/rails/blob/16dae7684edc480ee3fe65dfff8e19989402c987/
# actionview/app/assets/javascripts/rails-ujs/features/confirm.coffee

handleConfirm = (element) ->
  unless allowAction(this)
    Rails.stopEverything element

allowAction = (element) ->
  if element.getAttribute('data-confirm-with-edit-summary') == null
    return true

  confirmWithEdiSummary element
  false

# HACK: To work with `method: :delete` etc, see https://github.com/rails/rails/blob/16dae7684edc480ee3fe65dfff8e19989402c987/
# actionview/app/assets/javascripts/rails-ujs/features/method.coffee
appendEditSummary = (element, editSummary) ->
  href = element.href
  if href.indexOf("?") > 0
    alert "The developer as too lazy to implement the case with pre-existing query params, please send an angy email."

  # Crop to `Activity::EDIT_SUMMARY_MAX_LENGTH` to avoid validation isses.
  editSummary = editSummary.substr 0, 255
  element.href = "#{href}?edit_summary=#{encodeURIComponent(editSummary)}"

confirmWithEdiSummary = (element) ->
  message = element.getAttribute('data-message') || "Are you sure?"

  placeholder = "Edit summary (optional, maximum 255 characters)"
  answer = window.prompt message, placeholder

  unless answer == null
    if answer != '' and answer != placeholder
      appendEditSummary element, answer

    element.removeAttribute('data-confirm-with-edit-summary')
    element.click()

document.addEventListener 'rails:attachBindings', (e) ->
  Rails.delegate(document, 'a[data-confirm-with-edit-summary]', 'click', handleConfirm)
