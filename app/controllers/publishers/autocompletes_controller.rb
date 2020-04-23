# frozen_string_literal: true

module Publishers
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_publishers
    end

    private

      def serialized_publishers
        publishers.map(&:display_name)
      end

      def publishers
        Autocomplete::PublishersQuery[params[:term]]
      end
  end
end
