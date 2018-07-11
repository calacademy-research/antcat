module References
  class ReviewsController < ApplicationController
    before_action :authenticate_superadmin, only: :approve_all
    before_action :authenticate_editor
    before_action :set_reference, only: [:start, :finish, :restart]

    # TODO handle error, if any. Also in `#finish_reviewing` and `#restart_reviewing`.
    # TODO allow JSON requests.
    def start
      @reference.start_reviewing!
      make_default_reference!
      redirect_back fallback_location: changes_path
    end

    def finish
      @reference.finish_reviewing!
      redirect_back fallback_location: changes_path
    end

    def restart
      @reference.restart_reviewing!
      make_default_reference!
      redirect_back fallback_location: changes_path
    end

    # TODO handle error, if any.
    def approve_all
      Reference.approve_all
      redirect_to references_latest_changes_path, notice: "Approved all references."
    end

    private
      def set_reference
        @reference = Reference.find params[:id]
      end

      def make_default_reference!
        DefaultReference.set session, @reference
      end
  end
end
