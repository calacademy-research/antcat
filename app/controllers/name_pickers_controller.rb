class NamePickersController < ApplicationController
  before_action :ensure_can_edit_catalog

  def search
    respond_to do |format|
      format.json do
        render json: Names::PicklistMatching[params[:term]]
      end
    end
  end
end
