# coding: UTF-8
require 'csv'

class PopulateAntwikiValidTaxa < ActiveRecord::Migration
  def up
    CSV.foreach('/Users/mwilden/cas/antwiki/AntWiki_Valid_Species.txt', col_sep: "\t", headers: false) do |row|
      AntwikiValidTaxon.create! row.to_hash
    end
  end
end
