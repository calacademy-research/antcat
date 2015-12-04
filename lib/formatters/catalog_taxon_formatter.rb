# coding: UTF-8
class Formatters::CatalogTaxonFormatter < Formatters::TaxonFormatter
  include Formatters::ButtonFormatter
  include Formatters::LinkFormatter


  #########
  public def header
    @taxon.decorate.header
  end

  public def change_history
    @taxon.decorate.change_history
  end

end
