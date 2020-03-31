# frozen_string_literal: true

class ActivitiesController < ApplicationController
  FILTER_TRACKABLE_TYPES = %w[
    Author
    AuthorName
    Change
    Comment
    Feedback
    Institution
    Issue
    Journal
    Name
    Protonym
    Reference
    ReferenceSection
    SiteNotice
    Synonym
    Taxon
    TaxonHistoryItem
    Tooltip
    User
    WikiPage
  ]

  before_action :ensure_user_is_superadmin, only: :destroy

  def index
    @activities = unpaginated_activities.by_ids_desc.includes(:user).paginate(page: params[:page])
  end

  def show
    activity = find_activity
    page = activity.pagination_page(unpaginated_activities)
    redirect_to activities_path(id: activity.id, page: page, anchor: activity.decorate.css_anchor_id)
  end

  def destroy
    activity = find_activity
    activity.destroy
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

    # TODO: Rename `activities.action` --> `activities.action_name`.
    # HACK: Because `params[:action]` (to filter on `activitie.actions`) gets
    # overridden by Rails (controller action param).
    def filter_params
      params.permit(:activity_action, :trackable_type, :trackable_id, :user_id).tap do |hsh|
        hsh[:action] = hsh.delete(:activity_action)
      end
    end
end
