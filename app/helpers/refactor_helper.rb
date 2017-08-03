# This is a relic from migrating all Formatters to Decorators.
# TODO remove.
#
# [November 2016]: this module is included in:
#   app/decorators/taxon_decorator/child_list.rb
#   app/decorators/taxon_decorator/headline.rb
#
# Calls to individual methods:
#   #link_to_taxon
#     child_list.rb
#     headline.rb
#
#   #link_to_other_site
#      headline.rb

module RefactorHelper
  def link_to_taxon taxon
    if $use_ant_web_formatter
      Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
    else
      taxon.decorate.link_to_taxon
    end
  end

  def link_to_other_site
    if $use_ant_web_formatter
      Exporters::Antweb::Exporter.antcat_taxon_link @taxon
    else
      link_to_antweb @taxon
    end
  end
end
