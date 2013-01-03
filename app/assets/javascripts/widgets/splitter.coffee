window.AntCat or= {}

class AntCat.Splitter

  constructor: (@element, @on_change) ->
    @element.draggable(axis: 'y', cursor: 'row-resize', drag: @drag)

  drag: =>
    @on_change(@element.css('top')) if @on_change
