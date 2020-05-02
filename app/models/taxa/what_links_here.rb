# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    TAXA_COLUMNS_REFERENCING_TAXA = %i[
      subfamily_id
      tribe_id
      genus_id
      subgenus_id
      species_id
      subspecies_id

      current_valid_taxon_id
      homonym_replaced_by_id
      type_taxon_id
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
      @_columns ||= Taxa::WhatLinksHereColumns[taxon]
    end

    def any_columns?
      return @_any_columns if defined? @_any_columns
      @_any_columns ||= Taxa::WhatLinksHereColumns[taxon, predicate: true]
    end

    def taxts
      @_taxts ||= Taxa::WhatLinksHereTaxts[taxon]
    end

    def any_taxts?
      return @_any_taxts if defined? @_any_taxts
      @_any_taxts ||= Taxa::WhatLinksHereTaxts[taxon, predicate: true]
    end
  end
end
