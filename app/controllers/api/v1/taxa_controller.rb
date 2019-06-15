module Api
  module V1
    class TaxaController < Api::ApiController
      def index
        super Taxon
      end

      def show
        super Taxon
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
          head :not_found
        end
      end
    end
  end
end
