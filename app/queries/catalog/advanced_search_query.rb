# frozen_string_literal: true

module Catalog
  class AdvancedSearchQuery
    include Service

    TAXA_COLUMNS = %i[
      unresolved_homonym status type collective_group_name
      incertae_sedis_in
    ]
    PROTONYM_COLUMNS = %i[fossil nomen_nudum ichnotaxon]
    NAME_SEARCH_TYPES = [
      NAME_CONTAINS = 'contains',
      NAME_MATCHES = 'matches',
      NAME_BEGINS_WITH = 'begins_with'
    ]
    HISTORY_ITEMS = [
      MUST_HAVE_HISTORY_ITEMS = 'must_have',
      CANNOT_HAVE_HISTORY_ITEMS = 'cannot_have'
    ]
    BIOREGION_NONE = 'None'

    def initialize params
      @params = params.compact_blank!
    end

    def call
      return Taxon.none if params.blank?
      search_results.includes(:name, protonym: { authorship: :reference })
    end

    private

      attr_reader :params

      def search_results
        relation = Taxon.joins(protonym: [{ authorship: :reference }]).order_by_name

        TAXA_COLUMNS.each do |column|
          relation = relation.where(column => params[column]) if params[column]
        end
        PROTONYM_COLUMNS.each do |column|
          relation = relation.where(protonyms: { column => params[column] }) if params[column]
        end

        relation = relation.valid if params[:valid_only]

        relation.
          then(&method(:history_items_clause)).
          then(&method(:author_name_clause)).
          then(&method(:years_clause)).
          then(&method(:name_clause)).
          then(&method(:epithet_clause)).
          then(&method(:genus_clause)).
          then(&method(:protonym_clause)).
          then(&method(:type_information_clause)).
          then(&method(:locality_clause)).
          then(&method(:bioregion_clause)).
          then(&method(:forms_clause))
      end

      def history_items_clause relation
        return relation unless (history_items = params[:history_items])

        case history_items
        when MUST_HAVE_HISTORY_ITEMS
          relation.distinct.joins(:protonym_history_items)
        when CANNOT_HAVE_HISTORY_ITEMS
          relation.left_joins(:protonym_history_items).where(history_items: { protonym_id: nil })
        end
      end

      def author_name_clause relation
        return relation unless (author_name = params[:author_name])

        author_author_names = AuthorName.find_by!(name: author_name).author.names
        TaxonQuery.new(relation).with_common_includes.
          where(reference_author_names: { author_name_id: author_author_names })
      end

      def years_clause relation
        return relation unless (year = params[:year])

        if year.match?(/^\d{4,}$/)
          relation.where(references: { year: year })
        elsif (matches = year.match(/^(?<start_year>\d{4})-(?<end_year>\d{4})$/))
          relation.where('references.year BETWEEN ? AND ?', matches[:start_year], matches[:end_year])
        else
          relation
        end
      end

      def name_clause relation
        return relation unless (name = params[:name]&.strip.presence)

        case params[:name_search_type]
        when NAME_MATCHES     then relation.where("names.name = ?", name)
        when NAME_BEGINS_WITH then relation.where("names.name LIKE ?", name + '%')
        else                       relation.where("names.name LIKE ?", '%' + name + '%')
        end.joins(:name)
      end

      def epithet_clause relation
        return relation unless (epithet = params[:epithet]&.strip.presence)
        relation.joins(:name).where(names: { epithet: epithet })
      end

      def genus_clause relation
        return relation unless (genus = params[:genus]&.strip.presence)

        relation.joins('JOIN taxa genera ON genera.id = taxa.genus_id').
          joins('JOIN names genus_names ON genus_names.id = genera.name_id').
          where('genus_names.name LIKE ?', "%#{genus}%")
      end

      def protonym_clause relation
        return relation unless (protonym = params[:protonym]&.strip.presence)

        relation.joins('JOIN names protonym_names ON protonym_names.id = protonyms.name_id').
          where('protonym_names.name LIKE ?', "%#{protonym}%")
      end

      def type_information_clause relation
        return relation unless (type_information = params[:type_information])

        relation.where(<<~SQL.squish, search_term: "%#{type_information}%")
          protonyms.primary_type_information_taxt LIKE :search_term
            OR protonyms.secondary_type_information_taxt LIKE :search_term
            OR protonyms.type_notes_taxt LIKE :search_term
        SQL
      end

      def locality_clause relation
        return relation unless (locality = params[:locality])
        relation.where('protonyms.locality LIKE ?', "%#{locality}%")
      end

      def bioregion_clause relation
        return relation unless (bioregion = params[:bioregion])

        value = bioregion == BIOREGION_NONE ? nil : bioregion
        relation.where(protonyms: { bioregion: value })
      end

      def forms_clause relation
        return relation unless (forms = params[:forms])
        relation.where('protonyms.forms LIKE ?', "%#{forms}%")
      end
  end
end
