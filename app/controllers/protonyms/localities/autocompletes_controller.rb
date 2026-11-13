# frozen_string_literal: true

# Type locality lookup while typing.
#
# Routes: GET /protonyms/localities/autocomplete (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Protonyms
  module Localities
    class AutocompletesController < ApplicationController
      def show
        render json: serialized_localities
      end

      private

        def serialized_localities
          Locality.unique_sorted
        end
    end
  end
end
