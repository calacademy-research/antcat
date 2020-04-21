# frozen_string_literal: true

module Protonyms
  module Localities
    class AutocompletesController < ApplicationController
      def show
        respond_to do |format|
          format.json { render json: serialized_localities }
        end
      end

      private

        def serialized_localities
          Locality.unique_sorted
        end
    end
  end
end
