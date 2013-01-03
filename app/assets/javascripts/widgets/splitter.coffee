window.AntCat or= {}

class AntCat.Splitter

  constructor: (@element, @on_change) ->
    @element.draggable(axis: 'y', cursor: 'move', drag: @drag)
    @element.addClass('ui-widget-content')

  drag: =>
    @on_change(@element.css('top')) if @on_change
