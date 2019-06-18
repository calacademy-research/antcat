class ActivitiesController < ApplicationController
  include HasWhereFilters

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
  ]

  before_action :ensure_user_is_superadmin, only: :destroy
  before_action :set_activity, only: :destroy

  has_filters(
    user_id: {
      tag: :select_tag,
      options: -> { User.order(:name).pluck(:name, :id) }
    },
    trackable_type: {
      tag: :select_tag,
      options: -> { FILTER_TRACKABLE_TYPES }
    },
    trackable_id: {
      tag: :number_field_tag
    },
    activity_action: {
      tag: :select_tag,
      options: -> { Activity::ACTIONS.map(&:humanize).zip(Activity::ACTIONS) },
      prompt: "Action"
    }
  )

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
        activities = Activity.filter(hacked_filter_params)
        unless params[:show_automated_edits]
          activities = activities.non_automated_edits
        end
        activities
      end
    end

    # HACK to make this work at the same time:
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

    # HACK because `params[:action]` (to filter on `activitie.actions`) gets
    # overridden by Rails (controller action param).
    def hacked_filter_params
      filter_params.tap do |hsh|
        hsh[:action] = hsh.delete(:activity_action)
      end
    end
end
