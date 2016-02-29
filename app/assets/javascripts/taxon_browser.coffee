$ ->
  $("#close_inactive_panels").checkboxCookify true
  $("#keep_taxon_browser_open").checkboxCookify false

  setTaxonBrowserVisibility() # run before TaxonBrowserToggler

  new TaxonBrowserToggler()

# "Keep open" means "continue to be open", not "always open".
# If the browser is hidden, it stays hidden. Like this:
#
#                  keep_open_on  keep_open_off
# browser_hidden       HIDE          HIDE
# browser_visible      SHOW          HIDE
setTaxonBrowserVisibility = ->
  # browser is hidden --> don't do anything
  browserHidden = Cookies.get("show_browser") != "true"
  return if browserHidden

  # keep open disabled --> hide
  unless Cookies.get("keep_taxon_browser_open") == "true"
    Cookies.set "show_browser", "false"
