# coding: UTF-8
module Formatters::AdvancedSearchTextFormatter
  include Formatters::AdvancedSearchFormatter

  def format taxon, user
    format_name(taxon) + ' ' + format_status(taxon) + ' ' + format_protonym(taxon, user)
  end

  def format_name taxon
    taxon.name_cache
  end

end
