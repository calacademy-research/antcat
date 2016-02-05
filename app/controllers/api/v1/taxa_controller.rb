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

    # Search for known present species
    # search for known absent species
    def search
      q = params[:string] || ''
      search_results = Taxon.where("name_cache LIKE ?", "%#{q}%").take(10)
      results = search_results.map do |taxon|
        {
            id: taxon.id,
            name: taxon.name_cache
        }
      end
      if results.size > 0
        render json: results
      else
        render nothing: true, status: :not_found
      end
    end
  end
end


