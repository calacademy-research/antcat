$ ->
  $("*[data-highlight-text]").each ->
    element = this
    highlightText = $(this).data "highlight-text"
    highlight highlightText, element

highlight = (text, element) ->
  regexp = new RegExp(text, 'g')
  element.innerHTML = element.innerHTML.replace regexp, "<span class='highlight'>#{text}</span>"
  null
