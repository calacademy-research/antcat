class Taxa::Search

  def self.find_name name, search_type
    return Taxon.none if name.blank?

    search_type ||= "beginning_with"

    name = name.dup.strip
    query = Taxon.ordered_by_name
    column = name.split(' ').size > 1 ? 'name' : 'epithet'

    query = case search_type
            when 'matching'
              query.where(["names.#{column} = ?", name])
            when 'beginning_with'
              query.where(["names.#{column} LIKE ?", name + '%'])
            when 'containing'
              query.where(["names.#{column} LIKE ?", '%' + name + '%'])
            end
    query.all
  end

  def self.advanced_search params
    params[:biogeographic_region] = '' if params[:biogeographic_region] == 'Any'

    return Taxon.none unless params[:author_name].present? ||
        params[:locality].present? ||
        params[:verbatim_type_locality].present? ||
        params[:type_specimen_repository].present? ||
        params[:type_specimen_code].present? ||
        params[:year].present? ||
        params[:biogeographic_region].present? ||
        params[:rank].present? && params[:rank] != 'All' ||
        params[:genus].present? ||
        params[:forms].present?

    query = Taxon.joins(protonym: [{authorship: :reference}])
    query = query.where(type: params[:rank]) unless params[:rank] == 'All'
    query = query.where(status: 'valid') if params[:valid_only].present?
    query = query.order(:name_cache)

    if params[:author_name].present?
      author_name = AuthorName.find_by_name(params[:author_name])
      return Taxon.none unless author_name.present?
      query = query
        .where('reference_author_names.author_name_id' => author_name.author.names)
        .joins('JOIN reference_author_names ON reference_author_names.reference_id = `references`.id')
        .joins('JOIN author_names ON author_names.id = reference_author_names.author_name_id')
    end

    query = query.where('references.year = ?', params[:year]) if params[:year].present?

    search_term = "%#{params[:locality]}%"
    query = query.where('protonyms.locality LIKE ?', search_term) if params[:locality].present?

    search_term = "%#{params[:verbatim_type_locality]}%"
    query = query.where('verbatim_type_locality LIKE ?', search_term) if params[:verbatim_type_locality].present?

    search_term = "%#{params[:type_specimen_repository]}%"
    query = query.where('type_specimen_repository LIKE ?', search_term) if params[:type_specimen_repository].present?

    search_term = "%#{params[:type_specimen_code]}%"
    query = query.where('type_specimen_code LIKE ?', search_term) if params[:type_specimen_code].present?

    if params[:genus].present?
      query = query.joins('inner JOIN taxa as genera ON genera.id = taxa.genus_id')
      query = query.joins('inner JOIN names as genus_names ON  genera.name_id = genus_names.id')
      search_term = "%#{params[:genus]}%"
      query = query.where('genus_names.name like ?', search_term)
    end

    search_term = params[:biogeographic_region]
    if search_term == 'None'
      query = query.where biogeographic_region: nil
    elsif search_term.present?
      query = query.where(biogeographic_region: search_term)
    end

    search_term = "%#{params[:forms]}%"
    query = query.where('forms LIKE ?', search_term) if params[:forms].present?

    query
  end

end
