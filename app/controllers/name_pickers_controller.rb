class NamePickersController < ApplicationController
  before_action :ensure_can_edit_catalog

  def search
    options = {}
    options[:species_only] = true if params[:species_only].present?
    options[:genera_only] = true if params[:genera_only].present?
    options[:subfamilies_or_tribes_only] = true if params[:subfamilies_or_tribes_only].present?

    respond_to do |format|
      format.json do
        render json: Names::PicklistMatching[params[:term], options]
      end
    end
  end
end
