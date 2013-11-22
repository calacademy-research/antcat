# coding: UTF-8
class Taxon < ActiveRecord::Base

  def self.advanced_search params
    params[:biogeographic_region] = '' if params[:biogeographic_region] == 'Any'

    return where('1 = 0') unless
      params[:author_name].present? ||
      params[:locality].present? ||
      params[:verbatim_type_locality].present? ||
      params[:year].present? ||
      params[:biogeographic_region].present? ||
      params[:rank].present? && params[:rank] != 'All'

    query = joins protonym: [{authorship: :reference}]
    query = query.where type: params[:rank] unless params[:rank] == 'All'
    query = query.where status: 'valid' if params[:valid_only].present?
    query = query.order :name_cache

    if params[:author_name].present?
      author_name = AuthorName.find_by_name params[:author_name]
      return where('1 = 0') unless author_name.present?
      query = query.where 'reference_author_names.author_name_id' => author_name.author.names
      query = query.joins 'JOIN reference_author_names ON reference_author_names.reference_id = `references`.id'
      query = query.joins 'JOIN author_names ON author_names.id = reference_author_names.author_name_id'
    end

    query = query.where('references.year = ?', params[:year]) if params[:year].present?

    search_term = "%#{params[:locality]}%"
    query = query.where('protonyms.locality LIKE ?', search_term) if params[:locality].present?

    search_term = "%#{params[:verbatim_type_locality]}%"
    query = query.where('verbatim_type_locality LIKE ?', search_term) if params[:verbatim_type_locality].present?

    search_term = params[:biogeographic_region]
    if search_term == 'None'
      query = query.where biogeographic_region: nil
    else
      query = query.where(biogeographic_region: search_term) if search_term.present?
    end

    query

  end

end
