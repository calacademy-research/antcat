# frozen_string_literal: true

# Reference lookup for links in text.
#
# Routes: GET /references/linkable_autocomplete (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module References
  class LinkableAutocompletesController < ApplicationController
    # For at.js. Not as advanced as `References::AutocompletesController`.
    def show
      render json: serialized_references
    end

    private

      def serialized_references
        Autocomplete::LinkableReferencesSerializer[references]
      end

      def references
        search_query = params[:q] || ''
        Autocomplete::LinkableReferencesQuery[search_query]
      end
  end
end
