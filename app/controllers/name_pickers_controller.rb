class NamePickersController < ApplicationController
  def search
    respond_to do |format|
      format.json do
        render json: Names::PicklistMatching[params[:term]]
      end
    end
  end
end
