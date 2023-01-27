# frozen_string_literal: true

class PickerComponent < ApplicationComponent
  NUM_CATALOG_RESULTS = 7

  def initialize pickable_type, record, name:, id: nil, ranks: nil
    @pickable_type = pickable_type
    @record = record
    @name = name
    @id = id || name
    @ranks = Array.wrap(ranks)
  end

  def label
    return unless record

    case pickable_type
    when :taxon     then CatalogFormatter.link_to_taxon_with_linked_author_citation(record)
    when :protonym  then CatalogFormatter.link_to_protonym_with_linked_author_citation(record)
    when :reference then record.decorate.link_to_reference
    else            raise "unsupported pickable_type"
    end
  end

  def autocomplete_url
    case pickable_type
    when :taxon     then "/catalog/autocomplete.html?pickable_type=taxon&#{per_page_catalog}#{ranks_query}"
    when :protonym  then "/catalog/autocomplete.html?pickable_type=protonym&#{per_page_catalog}"
    when :reference then "/references/autocomplete.html?"
    else            raise "unsupported pickable_type"
    end
  end

  private

    attr_reader :pickable_type, :record, :name, :id, :ranks

    def ranks_query
      return if ranks.blank?
      "&#{ranks.to_query(:rank)}"
    end

    def per_page_catalog
      "per_page=#{NUM_CATALOG_RESULTS}"
    end
end
