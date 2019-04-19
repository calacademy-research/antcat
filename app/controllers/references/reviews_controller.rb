module References
  class ReviewsController < ApplicationController
    before_action :authenticate_superadmin, only: :approve_all
    before_action :ensure_can_edit_catalog
    before_action :set_reference, only: [:start, :finish, :restart]

    # TODO allow JSON requests.
    def start
      @reference.start_reviewing!
      redirect_back fallback_location: references_path
    end

    def finish
      @reference.finish_reviewing!
      redirect_back fallback_location: references_path
    end

    def restart
      @reference.restart_reviewing!
      redirect_back fallback_location: references_path
    end

    def approve_all
      Reference.approve_all
      redirect_to references_latest_changes_path, notice: "Approved all references."
    end

    private

      def set_reference
        @reference = Reference.find params[:id]
      end
  end
end
