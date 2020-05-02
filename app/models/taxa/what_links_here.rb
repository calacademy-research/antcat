# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    TAXT_TAG_METHOD = :tax_or_taxac_tag_regex
    REFERENCING_COLUMNS = [
      [Taxon, :subfamily_id],
      [Taxon, :tribe_id],
      [Taxon, :genus_id],
      [Taxon, :subgenus_id],
      [Taxon, :species_id],
      [Taxon, :subspecies_id],
      [Taxon, :current_valid_taxon_id],
      [Taxon, :homonym_replaced_by_id],
      [Taxon, :type_taxon_id]
    ]

    attr_private_initialize :record

    def all
      columns + taxts
    end

    def any?
      return @_any if defined? @_any
      @_any ||= any_columns? || any_taxts?
    end

    def columns
      @_columns ||= what_links_here_columns.all
    end

    def any_columns?
      return @_any_columns if defined? @_any_columns
      @_any_columns ||= what_links_here_columns.any?
    end

    def taxts
      @_taxts ||= what_links_here_taxts.all
    end

    def any_taxts?
      return @_any_taxts if defined? @_any_taxts
      @_any_taxts ||= what_links_here_taxts.any?
    end

    private

      def what_links_here_columns
        WhatLinksHereColumns.new(record, REFERENCING_COLUMNS)
      end

      def what_links_here_taxts
        WhatLinksHereTaxts.new(record, TAXT_TAG_METHOD)
      end
  end
end
