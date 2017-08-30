module References
  class ReviewsController < ApplicationController
    before_action :authenticate_superadmin, only: [:approve_all]
    before_action :set_reference, only: [:start, :finish, :restart]

    # TODO handle error, if any. Also in `#finish_reviewing` and `#restart_reviewing`.
    # TODO allow JSON requests.
    def start
      @reference.start_reviewing!
      make_default_reference @reference
      redirect_to latest_additions_references_path
    end

    def finish
      @reference.finish_reviewing!
      redirect_to latest_additions_references_path
    end

    def restart
      @reference.restart_reviewing!
      make_default_reference @reference
      redirect_to latest_additions_references_path
    end

    # TODO handle error, if any.
    def approve_all
      Reference.approve_all
      redirect_to latest_changes_references_path, notice: "Approved all references."
    end

    private
      def set_reference
        @reference = Reference.find params[:id]
      end

      def make_default_reference reference
        DefaultReference.set session, reference
      end
  end
end
