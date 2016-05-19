class @CatalogSplitter
  # In the order they appear on the HTML.
  CONTENT = "#content"
  HEADER = "#header"
  TAXON_DESCRIPTION = "#taxon_description"
  SPLITTER = "#splitter"
  TAXON_BROWSER = "#taxon_browser"

  constructor: ->
    @setDefaultHeights()

    # Callback on window resize.
    $(window).resize @setDefaultHeights

    $(SPLITTER).draggable axis: "y", stop: @onSplitterChange

  setDefaultHeights: =>
    # Set #content container height...
    @setHeight CONTENT, @heightOf(window) - @heightOf(HEADER)

    # Split content div equally on smaller screens.
    if @heightOf(CONTENT) < 600
      half = (@heightOf(CONTENT) - @heightOf(SPLITTER)) / 2
      @setHeight TAXON_BROWSER, half

    # If theres space below the taxon description, this pushes
    # down the taxon browser to the bottom. If there's no space,
    # set the size anyways so that a scrollbar is added.
    @autosize TAXON_DESCRIPTION

  # For TAXON_DESCRIPTION / TAXON_BROWSER.
  autosize: (element) ->
    height = @heightOf(CONTENT) - @heightOf(SPLITTER)
    height -= switch element
                when TAXON_BROWSER
                  @heightOf TAXON_DESCRIPTION
                when TAXON_DESCRIPTION
                  @heightOf TAXON_BROWSER
    @setHeight element, height

  onSplitterChange: =>
    top = $(SPLITTER).position().top
    $(SPLITTER).css "top", 0 # Hackish
    @setTaxonDescriptionHeight top - @heightOf(HEADER)

  setTaxonDescriptionHeight: (height) =>
    checkHeightConstraints = (height) =>
      minHeight = 50
      maxHeight = @heightOf(CONTENT) - minHeight

      return minHeight if height < minHeight
      return maxHeight if height > maxHeight
      height

    height = checkHeightConstraints height
    @setHeight TAXON_DESCRIPTION, height
    @autosize TAXON_BROWSER

  heightOf: (element) -> $(element).outerHeight()

  setHeight: (element, height) -> $(element).outerHeight height

$ ->
  $("#toggle_legend").click (event) ->
    event.preventDefault()
    $("#taxon_key").slideToggle()

  new CatalogSplitter()
