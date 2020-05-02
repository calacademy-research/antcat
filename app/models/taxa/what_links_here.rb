# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    TAXT_TAG_METHOD = :tax_or_taxac_tag_regex
    COLUMNS_REFERENCING_TAXA = [
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

    attr_private_initialize :taxon

    def all
      columns + taxts
    end

    def any?
      return @_any if defined? @_any
      @_any ||= any_columns? || any_taxts?
    end

    def columns
      @_columns ||= WhatLinksHereColumns.new(taxon, COLUMNS_REFERENCING_TAXA).all
    end

    def any_columns?
      return @_any_columns if defined? @_any_columns
      @_any_columns ||= WhatLinksHereColumns.new(taxon, COLUMNS_REFERENCING_TAXA).any?
    end

    def taxts
      @_taxts ||= WhatLinksHereTaxts.new(taxon, TAXT_TAG_METHOD).all
    end

    def any_taxts?
      return @_any_taxts if defined? @_any_taxts
      @_any_taxts ||= WhatLinksHereTaxts.new(taxon, TAXT_TAG_METHOD).any?
    end
  end
end
