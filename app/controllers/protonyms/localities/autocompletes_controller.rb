# frozen_string_literal: true

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
