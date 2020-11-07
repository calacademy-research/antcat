# frozen_string_literal: true

module References
  class ReviewsController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :ensure_user_is_superadmin, only: :approve_all

    def start
      reference = find_reference

      reference.start_reviewing!
      reference.create_activity Activity::START_REVIEWING, current_user

      redirect_back fallback_location: references_path
    end

    def finish
      reference = find_reference

      reference.finish_reviewing!
      reference.create_activity Activity::FINISH_REVIEWING, current_user

      redirect_back fallback_location: references_path
    end

    def restart
      reference = find_reference

      reference.restart_reviewing!
      reference.create_activity Activity::RESTART_REVIEWING, current_user

      redirect_back fallback_location: references_path
    end

    def approve_all
      count = Reference.unreviewed.count

      # Manually update since Worflow does not allow approving unreviewed references of any state.
      Reference.unreviewed.find_each do |reference|
        reference.update!(review_state: Reference::REVIEW_STATE_REVIEWED)
      end

      Activity.create_without_trackable Activity::APPROVE_ALL_REFERENCES, current_user, parameters: { count: count }
      redirect_to references_latest_changes_path, notice: "Approved all references."
    end

    private

      def find_reference
        Reference.find(params[:id])
      end
  end
end
