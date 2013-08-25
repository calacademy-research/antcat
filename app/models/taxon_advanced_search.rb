# coding: UTF-8
class Taxon < ActiveRecord::Base

  def self.advanced_search params
    query = joins protonym: [{authorship: :reference}]
    query = query.where type: params[:rank] unless params[:rank] == 'All'
    query = query.where status: 'valid' if params[:valid_only].present?
    query = query.order :name_cache

    if params[:year].present? && params[:author_name].blank?
      query = query.where('references.year' => params[:year])

    elsif params[:author_name].present?
      author_names = AuthorName.find_by_name(params[:author_name]).author.names
      query = query.where 'reference_author_names.author_name_id' => author_names
      query = query.joins 'JOIN reference_author_names ON reference_author_names.reference_id = `references`.id'
      query = query.joins 'JOIN author_names ON author_names.id = reference_author_names.author_name_id'
      query = query.where 'references.year' => params[:year] if params[:year].present?

    else
      query = []

    end
    query
  end

end
