# frozen_string_literal: true

module My
  class RecentlyUsedReferencesController < ApplicationController
    NUMBER_OF_RECENT_REFERENCES = 15

    def show
      render json: Autocomplete::LinkableReferencesSerializer[recently_used_references]
    end

    def create
      update_most_recently_used_references
      head :ok
    end

    private

      # Most recent first. IDs of references that no longer exist are skipped.
      def recently_used_references
        ids = recently_used_reference_ids
        Reference.where(id: ids).index_by(&:id).values_at(*ids).compact
      end

      def update_most_recently_used_references
        id = Integer(params[:id].to_s, exception: false)
        return unless id && Reference.exists?(id)

        reference_ids = recently_used_reference_ids.prepend(id)
        session[:recently_used_reference_ids] = reference_ids.uniq[0...NUMBER_OF_RECENT_REFERENCES]
      end

      def recently_used_reference_ids
        Array.wrap(session[:recently_used_reference_ids]).filter_map { |id| Integer(id.to_s, exception: false) }
      end
  end
end
