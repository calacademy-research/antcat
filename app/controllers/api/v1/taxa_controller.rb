# coding: UTF-8
# rest endpoint - get taxa/[id]

module Api::V1
  class TaxaController < Api::ApiController
    def index
      if params[:starts_at]
        starts_at = params[:starts_at]
        taxa = Taxon.where('id >= ?',starts_at.to_i).order('id asc').limit('100')
      else
        taxa = Taxon.all.order('id asc').limit('100')

      end
      render json: taxa, status: :ok
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


