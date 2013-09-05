# coding: UTF-8
class Exporters::AdvancedSearchExporter
  include Formatters::AdvancedSearchTextFormatter

  def export user
    content = ''
    for taxon in Taxon.order(:name_cache).all
      content << format(taxon, user)
    end
    content
  end

end
