module Api
  module V1
    class TaxaController < Api::ApiController
      def index
        render json: with_limit(Taxon.all)
      end

      def show
        item = Taxon.find(params[:id])
        render json: item.to_json(methods: :author_citation)
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

        render json: results
      end
    end
  end
end
