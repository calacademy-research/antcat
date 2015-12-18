# FIX weird filename `tooltips_create.coffee`
# TODO find a method for letting editors test selectors
$ ->
  # currently statically generated TODO
  tooltipsToInsert = [
    ["label[for='reference_author_names_string']",
     "Ayyyy this tooltip found a place to live. Not editable though."]
  ]

  engine = new AntCat.Tooltips
  engine.insertTooltips tooltipsToInsert
  engine.tooltipifyAll()

class AntCat.Tooltips
  TOOLTIP_SELECTOR = 'img.help_icon'

  # Accepts an array of arrays in this format: [['jquery_selector', 'tooltip_text']]
  createTooltips: (tooltips) ->
    for tooltip in tooltips
      selector = tooltip[0]
      title    = tooltip[1]
      @createTooltip selector, title

  createTooltip: (selector, title) ->
    selector = $(selector)

    # Only insert if there's no tooltip already.
    unless selector.next().is TOOLTIP_SELECTOR
      iconElement = @_createIcon title
      $(iconElement).insertAfter selector

  # This method basically formats the tooltips.
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

  _createIcon: (title) ->
    '<img class="help_icon tooltip" title="' +
      title + '" src="/assets/help.png" alt="Help" />'