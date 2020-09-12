# frozen_string_literal: true

module Catalog
  class AdvancedSearchQuery # rubocop:disable Metrics/ClassLength
    include Service

    TAXA_COLUMNS = %i[
      fossil unresolved_homonym ichnotaxon hong status type collective_group_name
      incertae_sedis_in
    ]
    PROTONYM_COLUMNS = %i[nomen_nudum]
    NAME_SEARCH_TYPES = [
      NAME_CONTAINS = 'contains',
      NAME_MATCHES = 'matches',
      NAME_BEGINS_WITH = 'begins_with'
    ]
    HISTORY_ITEMS = [
      MUST_HAVE_HISTORY_ITEMS = 'must_have',
      CANNOT_HAVE_HISTORY_ITEMS = 'cannot_have'
    ]
    BIOGEOGRAPHIC_REGION_NONE = 'None'

    def initialize params
      @params = params.delete_if { |_key, value| value.blank? }
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
          yield_self(&method(:history_items_clause)).
          yield_self(&method(:author_name_clause)).
          yield_self(&method(:years_clause)).
          yield_self(&method(:name_clause)).
          yield_self(&method(:epithet_clause)).
          yield_self(&method(:genus_clause)).
          yield_self(&method(:protonym_clause)).
          yield_self(&method(:type_information_clause)).
          yield_self(&method(:locality_clause)).
          yield_self(&method(:biogeographic_region_clause)).
          yield_self(&method(:forms_clause))
      end

      def history_items_clause relation
        return relation unless (history_items = params[:history_items])

        case history_items
        when MUST_HAVE_HISTORY_ITEMS
          relation.distinct.joins(:history_items)
        when CANNOT_HAVE_HISTORY_ITEMS
          relation.left_outer_joins(:history_items).where(taxon_history_items: { taxon_id: nil })
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
          relation.where('references.year = ?', year)
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
        relation.joins(:name).where('names.epithet = ?', epithet)
      end

      def genus_clause relation
        return relation unless (genus = params[:genus]&.strip.presence)

        relation.joins('JOIN taxa AS genera ON genera.id = taxa.genus_id').
          joins('JOIN names AS genus_names ON genera.name_id = genus_names.id').
          where('genus_names.name LIKE ?', "%#{genus}%")
      end

      def protonym_clause relation
        return relation unless (protonym = params[:protonym]&.strip.presence)

        relation.joins('JOIN names AS protonym_names ON protonyms.name_id = protonym_names.id').
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

      def biogeographic_region_clause relation
        return relation unless (biogeographic_region = params[:biogeographic_region])

        value = biogeographic_region == BIOGEOGRAPHIC_REGION_NONE ? nil : biogeographic_region
        relation.where(protonyms: { biogeographic_region: value })
      end

      def forms_clause relation
        return relation unless (forms = params[:forms])
        relation.where('protonyms.forms LIKE ?', "%#{forms}%")
      end
  end
end
