# coding: UTF-8
class Taxon < ActiveRecord::Base

  def self.advanced_search params
    query = joins(protonym: [{authorship: :reference}]).order(:name_cache)
    if params[:year].present? && params[:author_name].blank?
      query = query.where(type: params[:rank]) unless params[:rank] == 'All'
      query = query.where('references.year' => params[:year])
      query = query.where(status: 'valid') if params[:valid_only].present?
    elsif params[:author_name].present?
    else
      query = []
    end
    query
  end

end
