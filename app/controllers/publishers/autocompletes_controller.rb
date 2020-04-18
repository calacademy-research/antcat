# frozen_string_literal: true

module Publishers
  class AutocompletesController < ApplicationController
    def show
      render json: Autocomplete::PublishersQuery[params[:term]].map(&:display_name)
    end
  end
end
