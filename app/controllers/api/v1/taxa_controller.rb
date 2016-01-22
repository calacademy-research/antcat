# coding: UTF-8
# rest endpoint - get taxa/[id]

module Api::V1
  class TaxaController < Api::ApiController
    def index
      @taxa = Taxon.connection.select_all("SELECT id, name_cache AS name FROM taxa ORDER BY name_cache LIMIT 1000")
      respond_to do |format|
        format.json { render json: @taxa }
      end
    end


    def show
      begin
        taxa = Taxon.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end

      render json: taxa, status: :ok
    end

  end
end


