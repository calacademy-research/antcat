$ ->
  AntCat.show_taxon_browser = true
  $("#desktop-toggler, #mobile-toggler, #tiny-toggler").click ->
    toggle_taxon_browser()

toggle_taxon_browser = ->
  $("#taxon_browser").slideToggle("slow")

  AntCat.show_taxon_browser = !AntCat.show_taxon_browser
  update_toggler_labels()

update_toggler_labels = ->
  verb = if AntCat.show_taxon_browser then "Hide" else "Show"
  $("#desktop-toggler, #mobile-toggler").text "#{verb} Taxon Browser"
