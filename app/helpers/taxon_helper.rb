# coding: UTF-8
module TaxonHelper

  def name_description taxon
    Formatters::TaxonFormatter.new(taxon).name_description
  end

end
