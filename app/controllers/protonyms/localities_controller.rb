module Protonyms
  class LocalitiesController < ApplicationController
    def autocomplete
      respond_to do |format|
        format.json { render json: Locality.unique_sorted }
      end
    end
  end
end
