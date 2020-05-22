# frozen_string_literal: true

module Api
  module V1
    class TaxonSerializer
      attr_private_initialize :taxon

      def as_json _options = {}
        taxon.as_json(methods: :author_citation, root: true)
      end
    end
  end
end
