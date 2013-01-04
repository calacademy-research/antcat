window.AntCat or= {}

class AntCat.Splitter

  constructor: (@element, @on_change) ->
    @element.draggable(axis: 'y', cursor: 'row-resize', stop: @stop)

  stop: =>
    @on_change(@element.css('top')) if @on_change
