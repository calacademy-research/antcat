# This is a relic from migrating all Formatters to Decorators. Adding global variables
# is not something I (jonk) think is a Good Idea(tm), but it made rafactoring so much easier
# and $use_ant_web_formatter only enabled in 'lib/exporters/antweb/exporter.rb', which is
# run on a machine separate from production.
#
# TODO remove.
#
# [November 2016]: this module is included in:
#   app/decorators/taxon_decorator/child_list.rb
#   app/decorators/taxon_decorator/header.rb
#   app/decorators/taxon_decorator/headline.rb
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
      reference.decorate.format_inline_citation_for_antweb
    else
      reference.decorate.inline_citation
    end
  end
end
