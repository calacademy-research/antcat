module References
  class SearchController < ApplicationController
    before_action :redirect_if_search_matches_id, only: :index

    def index
      return redirect_to references_path unless user_is_searching?

      params[:q] = params[:reference_q]
      @references = References::Search::FulltextWithExtractedKeywords[params]
    end

    def help
    end

    private

      def user_is_searching?
        params[:reference_q].present? || params[:author_q].present?
      end

      def redirect_if_search_matches_id
        return if params[:reference_q].blank?

        id = params[:reference_q].strip
        if id =~ /^\d{5,}$/
          return redirect_to reference_path(id) if Reference.exists? id
        end
      end
  end
end
