# FIX weird filename `tooltips_create.coffee`
$ ->
  $.ajax 'tooltips/enabled_selectors', success: (data) -> # TODO improve this
    tooltipsToInsert = data
    (new AntCat.InsertDynamicTooltips).createTooltips tooltipsToInsert
    (new AntCat.Tooltipify).tooltipifyAll()

  # TODO create a method for letting editors test selectors. This is the beta:
  window.createTooltip = (new AntCat.InsertDynamicTooltips).createTooltip
  window.tooltipifyAll = (new AntCat.Tooltipify).tooltipifyAll

class AntCat.InsertDynamicTooltips
  TOOLTIP_SELECTOR = 'img.help_icon'

  # Accepts an array of arrays in this format:
  # [['jquery_selector', 'tooltip_text', 'id']]
  createTooltips: (tooltips) ->
    for tooltip in tooltips
      selector = tooltip[0]
      title    = tooltip[1]
      id       = tooltip[2]
      @createTooltip selector, title, id

  createTooltip: (selector, title, id) =>
    disable_edit_link = false # TODO add this, currently it's not possible to disable
    selector = $(selector)

    # Only insert if there's no tooltip already.
    unless selector.next().is TOOLTIP_SELECTOR
      iconElement = @_createIcon title, id
      $(iconElement).insertAfter selector

  _createIcon: (title, id) => # TODO move the link from this function
    '<a href="/tooltips/' + id + '"><img class="help_icon tooltip" title="' +
      title + '" src="/assets/help.png" alt="Help" /></a>'

class AntCat.Tooltipify
  # Wrapper function that formats the tooltips.
  #
  # `$('.tooltip').tooltip()` is built-into jQuery UI; it takes a selector
  # (class="tooltip" by convention), and "tooltipifies" all elements matching that selector;
  # whatever is in the `title` attribute on those elements is used as the tooltip text.
  tooltipifyAll: ->
    $('.tooltip').tooltip
      show: false # show immediately
      content: -> $(this).prop('title') # Without this, HTML is displayed as text.
      position:
        my: "left top"
        at: "right bottom"
      close: (event, ui) -> # Keep open if the tooltip is hovered.
        startHoverHandler = -> $(this).stop(true)
        stopHoverHandler = -> $(this).remove()
        ui.tooltip.hover startHoverHandler, stopHoverHandler