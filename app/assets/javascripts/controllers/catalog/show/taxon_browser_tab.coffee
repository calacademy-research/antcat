$ ->
  setupLoadTabButton()

setupLoadTabButton = ->
  spinner = $("#taxon_browser .shared-spinner")

  $(".load-tab").click (event) ->
    event.preventDefault()

    me = $(event.target)
    url = me.attr "href"
    tabId = me.data "tab-id"
    tab = $("##{tabId}")

    # HACK: To fix https://github.com/calacademy-research/antcat/issues/185
    # This appends eg. `?display=all_taxa_in_genus` to the URL.
    if tabId == "extra-tab"
      url += location.search

    spinner.show()
    tab.find(".section-that-can-be-capped").load url, =>
      removeLoadTabButton tab
      spinner.hide()

removeLoadTabButton = (tab) ->
  tab.find(".remove-after-loading-full-tab").remove()
