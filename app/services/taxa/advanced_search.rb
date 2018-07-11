# TODO cleanup after extracting into service object.
# TODO see if we really want to modify `params` here.

module Taxa
  class AdvancedSearch
    include Service

    def initialize params
      @params = params
    end

    def call
      params[:biogeographic_region] = '' if params[:biogeographic_region] == 'Any'
      params[:rank] = '' if params[:rank] == 'All'

      params.delete_if { |_key, value| value.blank? }
      return Taxon.none if params.blank?

      query = Taxon.joins(protonym: [{ authorship: :reference }]).order_by_name_cache

      query = query.where(status: params[:status]) if params[:status]
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

      search_term = "%#{params[:type_information]}%"
      query = query.where(<<-SQL, search_term: search_term) if params[:type_information]
        published_type_information LIKE :search_term
          OR additional_type_information LIKE :search_term
          OR type_notes LIKE :search_term
      SQL

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

    private
      attr_reader :params
  end
end
