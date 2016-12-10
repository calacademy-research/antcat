class ActivitiesController < ApplicationController
  before_action :authenticate_superadmin, only: [:destroy]
  before_action :set_activity, only: [:destroy]

  def index
    @activities = Activity.ids_desc.include_associations.paginate(page: page)
  end

  def destroy
    @activity.destroy
    redirect_to activities_path(page: params[:page]),
      notice: "Activity item ##{@activity.id} was successfully deleted."
  end

  private
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
end
