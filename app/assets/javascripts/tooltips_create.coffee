# FIX weird filename `tooltips_create.coffee`
$ ->
  (new AntCat.Tooltips).tooltipifyAll()

class AntCat.Tooltips
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