# frozen_string_literal: true

module Taxa
  module Search
    class AdvancedSearch
      include Service

      TAXA_COLUMNS = %i[
        fossil nomen_nudum unresolved_homonym ichnotaxon hong status type collective_group_name
        incertae_sedis_in
      ]

      def initialize params
        @params = params.delete_if { |_key, value| value.blank? }
      end

      def call
        return Taxon.none if params.blank?
        search_results
      end

      private

        attr_reader :params

        def search_results # rubocop:disable Metrics/PerceivedComplexity
          query = Taxon.joins(protonym: [{ authorship: :reference }]).order_by_name

          TAXA_COLUMNS.each do |column|
            query = query.where(column => params[column]) if params[column]
          end

          query = query.valid if params[:valid_only]
          query = query.distinct.joins(:history_items) if params[:must_have_history_items]

          if params[:author_name].present?
            author_name = AuthorName.find_by!(name: params[:author_name])
            query = query.
              where('reference_author_names.author_name_id' => author_name.author.names).
              joins('JOIN reference_author_names ON reference_author_names.reference_id = `references`.id').
              joins('JOIN author_names ON author_names.id = reference_author_names.author_name_id')
          end

          if params[:year]
            year = params[:year]

            if /^\d{4,}$/.match?(year)
              query = query.where('references.year = ?', year)
            else
              matches = year.match /^(?<start_year>\d{4})-(?<end_year>\d{4})$/
              if matches.present?
                query = query.where('references.year BETWEEN ? AND ?', matches[:start_year], matches[:end_year])
              end
            end
          end

          query = query.where('protonyms.locality LIKE ?', "%#{params[:locality]}%") if params[:locality]

          query = query.where(<<-SQL, search_term: "%#{params[:type_information]}%") if params[:type_information]
            primary_type_information_taxt LIKE :search_term
              OR secondary_type_information_taxt LIKE :search_term
              OR type_notes_taxt LIKE :search_term
          SQL

          if (name_q = params[:name]&.strip.presence)
            query = query.joins(:name)
            query = case params[:name_search_type]
                    when 'matches'
                      query.where("names.name = ?", name_q)
                    when 'begins_with'
                      query.where("names.name LIKE ?", name_q + '%')
                    else
                      query.where("names.name LIKE ?", '%' + name_q + '%')
                    end
          end

          if (epithet_q = params[:epithet]&.strip.presence)
            query = query.joins(:name).where('names.epithet = ?', epithet_q)
          end

          if (genus_q = params[:genus]&.strip.presence)
            query = query.joins('JOIN taxa AS genera ON genera.id = taxa.genus_id').
                      joins('JOIN names AS genus_names ON genera.name_id = genus_names.id').
                      where('genus_names.name LIKE ?', "%#{genus_q}%")
          end

          if (protonym_q = params[:protonym]&.strip.presence)
            query = query.joins('JOIN names AS protonym_names ON protonyms.name_id = protonym_names.id').
                      where('protonym_names.name LIKE ?', "%#{protonym_q}%")
          end

          search_term = params[:biogeographic_region]
          if search_term == 'None'
            query = query.where(protonyms: { biogeographic_region: nil })
          elsif search_term
            query = query.where(protonyms: { biogeographic_region: search_term })
          end

          query = query.where('forms LIKE ?', "%#{params[:forms]}%") if params[:forms]

          query.includes(:name, protonym: { authorship: :reference })
        end
    end
  end
end
