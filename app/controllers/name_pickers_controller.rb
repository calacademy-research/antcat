# coding: UTF-8
class NamePickersController < ApplicationController

  def search
    respond_to do |format|
      format.json {render json: Name.picklist_matching(params[:term]).to_json}
    end
  end

end
