$ ->
  (new Tooltipify).tooltipifyAll()

class Tooltipify
  tooltipifyAll: ->
    $('.jquery-tooltip').tooltip
      tooltipClass: "has-jquery-tooltip" # Custom class to avoid collision with Foundation's tooltips.
      show: false
      content: -> $(this).prop('title') # Without this, HTML is displayed as text.
      position:
        my: "left top"
        at: "right bottom"
      close: (event, ui) -> # Keep open if the tooltip is hovered.
        startHoverHandler = -> $(this).stop(true)
        stopHoverHandler = -> $(this).remove()
        ui.tooltip.hover startHoverHandler, stopHoverHandler
