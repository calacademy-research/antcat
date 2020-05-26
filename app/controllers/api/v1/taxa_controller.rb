# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::ApiController
      def index
        render json: with_limit(Taxon.all).map { |item| Api::V1::TaxonSerializer.new(item) }
      end

      def show
        item = Taxon.find(params[:id])
        render json: Api::V1::TaxonSerializer.new(item)
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
