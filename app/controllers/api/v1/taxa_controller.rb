# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::ApiController
      SEARCH_MIN_LENGTH = 2
      SEARCH_RESULTS = 10
      SEARCH_REQUESTS_PER_MINUTE = 60
      # Per Puma process, like `CspReportsController`; the app cache is a null store in tests.
      SEARCH_RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new(size: 4.megabytes)

      # Each search scans the taxa table, and `/v1/` is not behind the Cloudflare challenge.
      rate_limit to: SEARCH_REQUESTS_PER_MINUTE, within: 1.minute, only: :search, store: SEARCH_RATE_LIMIT_STORE,
        with: -> { render json: { error: "Too many requests. Please wait a minute." }, status: :too_many_requests }

      def index
        render json: with_limit(Taxon.includes(:name)).map { Api::V1::TaxonSerializer.new(it) }
      end

      def show
        item = Taxon.find(params.expect(:id))
        render json: Api::V1::TaxonSerializer.new(item)
      end

      def junior_synonyms
        taxon = Taxon.find(params.expect(:id))
        render json: taxon.junior_synonyms.includes(:name).map { Api::V1::TaxonSerializer.new(it) }
      end

      def search
        q = params[:string].to_s.strip
        return render json: [] if q.length < SEARCH_MIN_LENGTH

        search_results = Taxon.where("name_cache LIKE ?", "%#{Taxon.sanitize_sql_like(q)}%").limit(SEARCH_RESULTS)
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
