# TODO make simpler
# Run before TaxonBrowserToggler, because init modifies
# the taxon browser's show/hide cookie.

class @TaxonBrowserKeepOpen
  KEEP_OPEN_CHECKBOX = "#keep_taxon_browser_open"

  constructor: ->
    @_setupCheckbox KEEP_OPEN_CHECKBOX
    @_setTaxonBrowserVisibility()

  # Set checked per browser_keep_open cookie and add click handler.
  _setupCheckbox: (checkBox) ->
    $(checkBox).attr "checked", (@_getCookie() || false)
    @_setClickHandler $(checkBox)

  # "Keep open" means "continue to be open", not "always open".
  # If the browser is hidden, it stays hidden. Like this:
  #
  #                  keep_open_on  keep_open_off
  # browser_hidden       HIDE          HIDE
  # browser_visible      SHOW          HIDE
  _setTaxonBrowserVisibility: (checkBox) ->
    browserHidden = not Cookies.getJSON("browser_toggler")?.show
    return if browserHidden

    keepOpenEnabled = @_getCookie()
    if keepOpenEnabled
      # do nothing and let the taxon browser decide
    else
      # keep open disabled --> default state --> closed
      Cookies.set "browser_toggler", "show": false

  _setClickHandler: (checkBox) ->
    $(checkBox).change =>
      checked = $(checkBox).is(":checked")
      @_setCookie checked

  _getCookie: -> Cookies.getJSON("browser_keep_open")?.keep_open

  _setCookie: (keepOpen) -> Cookies.set "browser_keep_open", "keep_open": keepOpen
