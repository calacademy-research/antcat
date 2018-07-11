class ActivitiesController < ApplicationController
  include HasWhereFilters

  before_action :authenticate_superadmin, only: :destroy
  before_action :set_activity, only: :destroy

  has_filters(
    user_id: {
      tag: :select_tag,
      options: -> { User.order(:name).pluck(:name, :id) }
    },
    trackable_type: {
      tag: :select_tag,
      options: -> { Activity.distinct.pluck(:trackable_type).compact }
    },
    trackable_id: {
      tag: :number_field_tag
    },
    activity_action: {
      tag: :select_tag,
      options: -> { activity_actions_options_for_select },
      prompt: "Action"
    }
  )

  def index
    @activities = Activity.filter(hacked_filter_params)
    unless params[:show_automated_edits]
      @activities = @activities.non_automated_edits
    end
    @activities = @activities.ids_desc.include_associations.paginate(page: page)
  end

  def destroy
    @activity.destroy
    redirect_to activities_path(page: params[:page]),
      notice: "Activity item ##{@activity.id} was successfully deleted."
  end

  private
    def self.activity_actions_options_for_select
      Activity.distinct.pluck(:action, :action).map(&:humanize)
        .zip(Activity.distinct.pluck(:action, :action))
    end
    private_class_method :activity_actions_options_for_select

    # HACK to make this work at the same time:
    # * Highlight single activity item in context.
    # * Not showing `params[:page]` in single-activity-links.
    # * Make the delete button return to the previous page.
    # * Make will_paginate not go bananas. <-- This what makes everything hard.
    def page
      return params[:page] unless params[:id]

      activity = Activity.find params[:id]
      # `@page` is to make the delete button return to the previous page.
      @page = activity.pagination_page
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
