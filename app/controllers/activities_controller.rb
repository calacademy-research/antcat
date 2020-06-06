# frozen_string_literal: true

class ActivitiesController < ApplicationController
  FILTER_TRACKABLE_TYPES_BY_GROUP = {
    'Catalog (common)' => %w[
      Protonym
      Reference
      Taxon
      TaxonHistoryItem
    ],
    'Catalog (other)' => %w[
      Author
      AuthorName
      Institution
      Journal
      Name
      ReferenceSection
    ],
    'Non-catalog' => %w[
      Comment
      Feedback
      Issue
      SiteNotice
      Tooltip
      User
      WikiPage
    ],
    'Deprecated' => Activity::DEPRECATED_TRACKABLE_TYPES
  }

  before_action :ensure_user_is_superadmin, only: :destroy

  def index
    @activities = unpaginated_activities.most_recent_first.includes(:user).paginate(page: params[:page])
  end

  def show
    activity = find_activity
    page = activity.pagination_page(unpaginated_activities)
    redirect_to activities_path(id: activity.id, page: page, anchor: activity.decorate.css_anchor_id)
  end

  def destroy
    activity = find_activity
    activity.destroy!
    redirect_back fallback_location: root_path,
      notice: "Activity item ##{activity.id} was successfully deleted."
  end

  private

    def find_activity
      Activity.find(params[:id])
    end

    def unpaginated_activities
      activities = Activity.filter_where(filter_params)
      activities = activities.non_automated_edits unless params[:show_automated_edits]
      activities
    end

    # HACK: Because `params[:action]` (for filtering) is overridden by Rails (controller action param).
    def filter_params
      params.permit(:activity_action, :trackable_type, :trackable_id, :user_id).tap do |hsh|
        hsh[:action] = hsh.delete(:activity_action)
      end
    end
end
