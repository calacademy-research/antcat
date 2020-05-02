# frozen_string_literal: true

module References
  class WhatLinksHere
    TAXT_TAG_METHOD = :ref_tag_regex
    COLUMNS_REFERENCING_REFERENCES = [
      [Citation,  :reference_id],
      [Reference, :nesting_reference_id]
    ]

    attr_private_initialize :reference

    def all
      columns + taxts
    end

    def any?
      return @_any if defined? @_any
      @_any ||= any_columns? || any_taxts?
    end

    def columns
      @_columns ||= WhatLinksHereColumns.new(reference, COLUMNS_REFERENCING_REFERENCES).all
    end

    def any_columns?
      return @_any_columns if defined? @_any_columns
      @_any_columns ||= WhatLinksHereColumns.new(reference, COLUMNS_REFERENCING_REFERENCES).any?
    end

    def taxts
      @_taxts ||= WhatLinksHereTaxts.new(reference, TAXT_TAG_METHOD).all
    end

    def any_taxts?
      return @_any_taxts if defined? @_any_taxts
      @_any_taxts ||= WhatLinksHereTaxts.new(reference, TAXT_TAG_METHOD).any?
    end
  end
end
