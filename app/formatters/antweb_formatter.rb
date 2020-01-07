module AntwebFormatter
  module_function

  def link_to_taxon taxon
    Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
  end
end
