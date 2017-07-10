module Types
  class TypeSpecimenRepositoriesController < ApplicationController
    def autocomplete
      respond_to do |format|
        format.json { render json: TypeSpecimenRepository.unique_sorted }
      end
    end
  end
end
