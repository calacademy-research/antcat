# frozen_string_literal: true

module Protonyms
  module Localities
    class AutocompletesController < ApplicationController
      def show
        respond_to do |format|
          format.json { render json: Locality.unique_sorted }
        end
      end
    end
  end
end
