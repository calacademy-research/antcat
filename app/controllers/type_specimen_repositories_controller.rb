class TypeSpecimenRepositoriesController < ApplicationController
  def autocompletion_data
    respond_to do |format|
      format.json { render json: TypeSpecimenRepository.unique_sorted }
    end
  end
end
