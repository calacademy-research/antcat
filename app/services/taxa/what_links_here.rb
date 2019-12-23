# TODO: Figure out what to call things. "What Links Here" vs "table ref", etc.

module Taxa
  class WhatLinksHere
    include Service

    def initialize taxon, predicate: false
      @taxon = taxon
      @predicate = predicate
    end

    def call
      if predicate
        any_column_table_refs? || any_taxt_table_refs?
      else
        table_refs = []
        table_refs.concat column_table_refs
        table_refs.concat taxt_table_refs
      end
    end

    private

      attr_reader :taxon, :predicate

      delegate :id, to: :taxon

      def any_column_table_refs?
        Taxa::WhatLinksHereColumns[taxon, predicate: true]
      end

      def any_taxt_table_refs?
        Taxa::WhatLinksHereTaxts[taxon, predicate: true]
      end

      def column_table_refs
        Taxa::WhatLinksHereColumns[taxon]
      end

      def taxt_table_refs
        Taxa::WhatLinksHereTaxts[taxon]
      end
  end
end
