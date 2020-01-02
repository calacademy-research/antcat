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
  before_action :set_activity, only: :destroy

  def index
    @activities = unpaginated_activities.ids_desc.includes(:user).paginate(page: page)
  end

  def destroy
    @activity.destroy
    redirect_to activities_path(page: params[:page]),
      notice: "Activity item ##{@activity.id} was successfully deleted."
  end

  private

    def unpaginated_activities
      @unpaginated_activities ||= begin
        activities = Activity.filter_where(hacked_filter_params)
        unless params[:show_automated_edits]
          activities = activities.non_automated_edits
        end
        activities
      end
    end

    # HACK: To make this work at the same time:
    # * Highlight single activity item in context.
    # * Not showing `params[:page]` in single-activity-links.
    # * Make the delete button return to the previous page.
    # * Make will_paginate not go bananas. <-- This what makes everything hard.
    def page
      return params[:page] unless params[:id]

      activity = Activity.find(params[:id])
      # `@page` is also included in the views to make the delete button return to the previous page.
      @page = activity.pagination_page(unpaginated_activities)
    end

    def set_activity
      @activity = Activity.find(params[:id])
    end

    # HACK: Because `params[:action]` (to filter on `activitie.actions`) gets
    # overridden by Rails (controller action param).
    def hacked_filter_params
      params.permit(:user_id, :trackable_type, :trackable_id, :activity_action).tap do |hsh|
        hsh[:action] = hsh.delete(:activity_action)
      end
    end
end
