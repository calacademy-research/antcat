# Responsible for:
# * Toggle show/hide (handlers attached to the `TOGGLERS`):
#   * Toggle visibility
#   * Update the togglers' labels after toggling
#   * Save current visibility state in a cookie

class @TaxonBrowserToggler
  # Element we want to show/hide
  TAXON_BROWSER = "#taxon_browser"

  # Elements that can open/close the browser
  TOGGLERS = "#desktop-toggler, #mobile-toggler, #tiny-toggler"

  # Don't include "Hide/Show" in the tiny toggler's label -- it's too tiny!!
  LABELS_TO_UPDATE = "#desktop-toggler, #mobile-toggler"

  constructor: ->
    @isVisible = $(TAXON_BROWSER).is(":visible")
    @_updateLabels()
    @_setClickHandlers TOGGLERS

  toggle: ->
    @isVisible = !@isVisible
    Cookies.set "show_browser", @isVisible
    @_updateLabels()
    $(TAXON_BROWSER).slideToggle 200

  _setClickHandlers: (elements) -> $(elements).click => @toggle()

  _updateLabels: ->
    verb = if @isVisible then "Hide" else "Show"
    $(LABELS_TO_UPDATE).text "#{verb} Taxon Browser"
