# coding: UTF-8
class TaxaController < ApplicationController

  def new
  end

  def create
  end

  def edit
    @taxon = Taxon.find params[:id]
  end

  def update
    @taxon = Taxon.find params[:id] 

    unless update_name
      render :edit and return
    end
  end

  ###################
  def update_name
    begin
      name = Name.import genus_name: params[:genus][:name_attributes][:name]
    rescue ActiveRecord::RecordInvalid
      @taxon.name.name = params[:genus][:name_attributes][:name]
      @taxon.errors.add :base, "Name can't be blank"
      return
    end
    @taxon.update_attributes name: name
    redirect_to catalog_path @taxon
  end

end
