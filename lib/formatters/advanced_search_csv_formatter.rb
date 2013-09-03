# coding: UTF-8
module Formatters::AdvancedSearchCSVFormatter
  extend self 
  def header
    "name\trank\n"
  end

  def format taxon
    taxon.name_cache + "\t" + taxon.type + "\t\n"
  end

end
