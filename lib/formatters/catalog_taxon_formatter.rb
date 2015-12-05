# coding: UTF-8
class Formatters::CatalogTaxonFormatter < Formatters::TaxonFormatter

  def header
    @taxon.decorate.header
  end

  def change_history
    @taxon.decorate.change_history
  end

end
