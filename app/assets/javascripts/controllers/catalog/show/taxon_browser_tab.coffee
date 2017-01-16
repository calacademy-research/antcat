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

    spinner.show()
    tab.find(".section-that-can-be-capped").load url, =>
      window.unborkTaxonBrowserScrollbars()
      removeLoadTabButton tab
      spinner.hide()

removeLoadTabButton = (tab) ->
  tab.find(".remove-after-loading-full-tab").remove()
