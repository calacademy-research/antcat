# This is a relic from migrating all Formatters to Decorators. Adding global variables
# is not something I (jonk) think is a Good Idea(tm), but it made rafactoring so much easier
# and $use_ant_web_formatter only enabled in 'lib/exporters/antweb/exporter.rb', which is
# run on a machine separate from production.
#
# TODO remove.
#
# [January 2016]: this module is included in:
#   app/decorators/taxon_decorator/child_list.rb
#   app/decorators/taxon_decorator/header.rb
#   app/decorators/taxon_decorator/headline.rb
#   app/decorators/taxon_decorator/history.rb
#
# Calls to individual methods:
#   #link_to_taxon
#     child_list.rb
#     headline.rb
#
#   #link_to_other_site
#      headline.rb
#
#   #link_to_reference
#      headline.rb
#
#   #detaxt
#      headline.rb
#      history.rb

module RefactorHelper

  def link_to_taxon taxon
    if $use_ant_web_formatter
      link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
    else
      label = taxon.name.to_html_with_fossil(taxon.fossil?)
      content_tag :a, label, href: %{/catalog/#{taxon.id}}
    end
  end

  def link_to_other_site
    if $use_ant_web_formatter
      link_to_antcat @taxon
    else
      link_to_antweb @taxon
    end
  end

  def link_to_reference reference
    if $use_ant_web_formatter
      reference.decorate.to_link expansion: false
    else
      reference.decorate.to_link
    end
  end

  def detaxt taxt
    return '' unless taxt.present?
    if $use_ant_web_formatter
      Taxt.to_string taxt, expansion: false
    else
      Taxt.to_string taxt
    end
  end

end
