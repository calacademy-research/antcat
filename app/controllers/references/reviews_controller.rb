module References
  class ReviewsController < ApplicationController
    before_action :ensure_user_is_superadmin, only: :approve_all
    before_action :ensure_user_is_editor
    before_action :set_reference, only: [:start, :finish, :restart]

    # TODO allow JSON requests.
    def start
      @reference.start_reviewing!
      @reference.create_activity :start_reviewing
      redirect_back fallback_location: references_path
    end

    def finish
      @reference.finish_reviewing!
      @reference.create_activity :finish_reviewing
      redirect_back fallback_location: references_path
    end

    def restart
      @reference.restart_reviewing!
      @reference.create_activity :restart_reviewing
      redirect_back fallback_location: references_path
    end

    def approve_all
      count = Reference.unreviewed.count

      # Manually update since Worflow does not allow approving unreviewed references of any state.
      Reference.unreviewed.find_each do |reference|
        reference.update!(review_state: "reviewed")
      end

      Activity.create_without_trackable :approve_all_references, parameters: { count: count }
      redirect_to references_latest_changes_path, notice: "Approved all references."
    end

    private

      def set_reference
        @reference = Reference.find(params[:id])
      end
  end
end
