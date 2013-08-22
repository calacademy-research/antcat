# coding: UTF-8
class Taxon < ActiveRecord::Base

  def self.advanced_search params
    query = joins(protonym: [{authorship: :reference}])
    query = query.where(type: params[:rank]) unless params[:rank] == 'All'
    query = query.where('references.year' => params[:year]).order(:name_cache)
    query = query.where(status: 'valid') if params[:valid_only].present?
    query
  end

end
