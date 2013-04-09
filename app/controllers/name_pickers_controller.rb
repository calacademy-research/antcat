# coding: UTF-8
class NamePickersController < ApplicationController

  def search
    respond_to do |format|
      options = {}
      options = params[:taxa_only] ? {taxa_only: true} : {}
      format.json {render json: Name.picklist_matching(params[:term], options).to_json}
    end
  end

end
