# coding: UTF-8
module Formatters::AdvancedSearchTextFormatter
  include Formatters::AdvancedSearchFormatter

  def format taxon
    string = format_name taxon
    status = format_status taxon
    protonym = format_protonym taxon, nil
    string << ' ' + status if status.present?
    string << "\n"
    string << protonym if protonym.present?
    string << "\n"
    string
  end

  def format_name taxon
    taxon.name_cache
  end

end
