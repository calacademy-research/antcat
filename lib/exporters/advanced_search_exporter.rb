# coding: UTF-8
class Exporters::AdvancedSearchExporter
  include Formatters::AdvancedSearchTextFormatter

  def export
    content = ''
    for taxon in Taxon.order(:name_cache).all
      content << format(taxon)
    end
    content
  end

end
