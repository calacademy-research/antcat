# coding: UTF-8
class Api::TaxaController < ApplicationController
  def index
    @taxa = Taxon.connection.select_all("SELECT id, name_cache AS name FROM taxa ORDER BY name_cache LIMIT 1000")
    respond_to do |format|
      format.json { render json: @taxa }
    end
  end
  def show
    @taxa = Taxon.connection.select_all("SELECT id, name_cache AS name FROM taxa WHERE id = #{params[:id]} ORDER BY name_cache")
    respond_to do |format|
      format.json { render json: @taxa }
    end
  end
end
