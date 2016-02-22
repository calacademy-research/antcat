$ ->
  AntCat.show_taxon_browser = true
  $(".toggle-taxon-browser-js-hook").click ->
    toggle_taxon_browser()

toggle_taxon_browser = ->
  $("#taxon_browser").slideToggle("slow")

  AntCat.show_taxon_browser = !AntCat.show_taxon_browser
  update_toggler_labels()

update_toggler_labels = ->
  verb = if AntCat.show_taxon_browser
    "Hide"
  else
    "Show"

  all_togglers = $(".toggle-taxon-browser-js-hook")
  all_togglers.text "#{verb} taxon browser"
