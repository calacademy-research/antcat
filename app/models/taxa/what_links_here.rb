# frozen_string_literal: true

# TODO: Figure out what to call things. "What Links Here" vs "table ref", etc.
# TODO: This class has a different signature than `References::WhatLinksHere`.

module Taxa
  class WhatLinksHere
    def initialize taxon
      @taxon = taxon
    end

    def all
      columns + taxts
    end

    def any?
      return @any if defined?(@any)
      @any ||= any_columns? || any_taxts?
    end

    def columns
      @columns ||= Taxa::WhatLinksHereColumns[taxon]
    end

    def any_columns?
      return @any_columns if defined?(@any_columns)
      @any_columns ||= Taxa::WhatLinksHereColumns[taxon, predicate: true]
    end

    def taxts
      @taxts ||= Taxa::WhatLinksHereTaxts[taxon]
    end

    def any_taxts?
      return @any_taxts if defined?(@any_taxts)
      @any_taxts ||= Taxa::WhatLinksHereTaxts[taxon, predicate: true]
    end

    private

      attr_reader :taxon
  end
end
