class Taxa::Search
  def self.quick_search name, search_type: nil, valid_only: false
    return Taxon.none if name.blank?

    search_type ||= "beginning_with"
    valid_only = false if valid_only.blank?
    name = name.dup.strip
    column = name.split(' ').size > 1 ? 'name' : 'epithet'

    query = Taxon.ordered_by_name
    query = query.valid if valid_only
    query = case search_type
            when 'matching'
              query.where("names.#{column} = ?", name)
            when 'beginning_with'
              query.where("names.#{column} LIKE ?", name + '%')
            when 'containing'
              query.where("names.#{column} LIKE ?", '%' + name + '%')
            end
    query.includes(:name, protonym: { authorship: :reference })
  end

  def self.advanced_search params
    params[:biogeographic_region] = '' if params[:biogeographic_region] == 'Any'
    params[:rank] = '' if params[:rank] == 'All'

    params.delete_if { |_key, value| value.blank? }
    return Taxon.none if params.blank?

    query = Taxon.joins(protonym: [{ authorship: :reference }]).order(:name_cache)

    query = query.where(type: params[:rank]) if params[:rank]
    query = query.where(status: 'valid') if params[:valid_only]

    if params[:author_name].present?
      author_name = AuthorName.find_by(name: params[:author_name])
      return Taxon.none unless author_name.present?
      query = query
        .where('reference_author_names.author_name_id' => author_name.author.names)
        .joins('JOIN reference_author_names ON reference_author_names.reference_id = `references`.id')
        .joins('JOIN author_names ON author_names.id = reference_author_names.author_name_id')
    end

    if params[:year]
      year = params[:year]

      if year =~ /^\d{4,}$/
        query = query.where('references.year = ?', year)
      else
        matches = year.match /^(?<start_year>\d{4})-(?<end_year>\d{4})$/
        if matches.present?
          query = query.where('references.year BETWEEN ? AND ?', matches[:start_year], matches[:end_year])
        end
      end
    end

    search_term = "%#{params[:locality]}%"
    query = query.where('protonyms.locality LIKE ?', search_term) if params[:locality]

    search_term = "%#{params[:verbatim_type_locality]}%"
    query = query.where('verbatim_type_locality LIKE ?', search_term) if params[:verbatim_type_locality]

    search_term = "%#{params[:type_specimen_repository]}%"
    query = query.where('type_specimen_repository LIKE ?', search_term) if params[:type_specimen_repository]

    search_term = "%#{params[:type_specimen_code]}%"
    query = query.where('type_specimen_code LIKE ?', search_term) if params[:type_specimen_code]

    search_term = "%#{params[:name]}%"
    query = query.where('taxa.name_cache LIKE ?', search_term) if params[:name]

    if params[:genus]
      query = query.joins('inner JOIN taxa as genera ON genera.id = taxa.genus_id')
      query = query.joins('inner JOIN names as genus_names ON  genera.name_id = genus_names.id')
      search_term = "%#{params[:genus]}%"
      query = query.where('genus_names.name like ?', search_term)
    end

    search_term = params[:biogeographic_region]
    if search_term == 'None'
      query = query.where(biogeographic_region: nil)
    elsif search_term
      query = query.where(biogeographic_region: search_term)
    end

    search_term = "%#{params[:forms]}%"
    query = query.where('forms LIKE ?', search_term) if params[:forms]

    query.includes(:name, protonym: { authorship: :reference })
  end
end
