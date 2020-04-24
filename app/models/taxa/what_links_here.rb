# frozen_string_literal: true

# NOTE: This class has a different signature than `References::WhatLinksHere`.

module Taxa
  class WhatLinksHere
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
