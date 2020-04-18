# frozen_string_literal: true

module References
  class SearchController < ApplicationController
    before_action :redirect_if_search_matches_id, only: :index

    def index
      return redirect_to references_path unless user_is_searching?

      fulltext_params = References::Search::ExtractKeywords[params[:reference_q]]
      @references = References::FulltextSearchQuery[**fulltext_params, page: params[:page]]
    end

    def help
    end

    private

      def user_is_searching?
        params[:reference_q].present?
      end

      def redirect_if_search_matches_id
        return if params[:reference_q].blank?

        id = params[:reference_q].strip
        return unless id =~ /^\d+$/ && Reference.exists?(id.to_i)
        redirect_to reference_path(id)
      end
  end
end
