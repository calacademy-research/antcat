# coding: UTF-8
class NamePickersController < ApplicationController

  def search
    respond_to do |format|
      options = {}
      options[:taxa_only] = true if params[:taxa_only].present?
      options[:species_only] = true if params[:species_only].present?
      options[:genera_only] = true if params[:genera_only].present?
      options[:subfamilies_or_tribes_only] = true if params[:subfamilies_or_tribes_only].present?
      format.json {render json: Name.picklist_matching(params[:term], options).to_json}
    end
  end

end
