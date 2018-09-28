$ ->
  catalogSplitter = new CatalogSplitter()

  window.unborkTaxonBrowserScrollbars = ->
    catalogSplitter.unborkTaxonBrowserScrollbars()

class @CatalogSplitter
  HEADER = "#header"
  CONTENT = "#content" # Everything except the header and feedback modal is nested here.

  # These three from `catalog/show.haml` are siblings (ie not nested).
  TAXON_DESCRIPTION = "#taxon_description"
  SPLITTER = "#splitter"
  TAXON_BROWSER = "#taxon_browser"

  constructor: ->
    @setDefaultHeights()

    # Run `@setDefaultHeights` callback on window resize.
    $(window).resize @setDefaultHeights

    # Make splitter draggable and set callback on stop dragging.
    $(SPLITTER).draggable axis: "y", stop: @onSplitterChange

    @setDefaultHeights()

  setDefaultHeights: =>
    @setHeight CONTENT, @heightOf(window) - @heightOf(HEADER)

    # Don't allow the taxon browser to take up more than half of the content.
    half_content_size = (@heightOf(CONTENT) - @heightOf(SPLITTER)) / 2
    if @heightOf(TAXON_BROWSER) > half_content_size
      @setHeight TAXON_BROWSER, half_content_size

    # If theres space below the taxon description, this pushes
    # down the taxon browser to the bottom. If there's no space,
    # set the size anyways so that a scrollbar is added.
    @autosize TAXON_DESCRIPTION

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
    $(SPLITTER).css "top", 0 # HACKish
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

  # Call this to unbork. You know it's borked if there's no scrollbars.
  unborkTaxonBrowserScrollbars: -> @autosize TAXON_BROWSER

  heightOf: (element) -> $(element).outerHeight true

  setHeight: (element, height) -> $(element).outerHeight height
