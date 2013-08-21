# coding: UTF-8
class Taxon < ActiveRecord::Base

  def self.advanced_search type, year, is_valid
    query = joins(protonym: [{authorship: :reference}])
    query = query.where(type: type) unless type == 'All'
    query = query.where('references.year' => year).order(:name_cache)
    query = query.where(status: 'valid') if is_valid
    query
  end

end
