# coding: UTF-8
class Taxon < ActiveRecord::Base

  def self.advanced_search type, year
    joins(protonym: [{authorship: :reference}]).where(type: type, 'references.year' => year)
  end

end
