module My
  class RecentlyUsedReferencesController < ApplicationController
    NUMBER_OF_RECENT_REFERENCES = 15

    def show
      render json: Autocomplete::FormatLinkableReferences[recently_used_references]
    end

    def create
      update_most_recently_used_references!
      head :ok
    end

    private

      def recently_used_references
        Reference.find(session[:recently_used_reference_ids] || [])
      end

      def update_most_recently_used_references!
        reference_ids = session[:recently_used_reference_ids] || []
        reference_ids.prepend params[:id]
        session[:recently_used_reference_ids] = reference_ids.uniq[0...NUMBER_OF_RECENT_REFERENCES]
      end
  end
end
