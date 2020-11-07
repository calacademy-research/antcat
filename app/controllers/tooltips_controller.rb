# frozen_string_literal: true

class TooltipsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:index]
  before_action :ensure_user_is_superadmin, only: [:destroy]

  def index
    @grouped_tooltips = Tooltip.order(:key).group_by(&:scope)
  end

  def show
    @tooltip = find_tooltip
  end

  def new
    @tooltip = Tooltip.new(key: params[:key], scope: params[:scope])
  end

  def create
    @tooltip = Tooltip.new(tooltip_params)
    if @tooltip.save
      @tooltip.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @tooltip, notice: 'Tooltip was successfully created.'
    else
      render :new
    end
  end

  def edit
    redirect_to action: :show
  end

  def update
    @tooltip = find_tooltip

    if @tooltip.update(tooltip_params)
      @tooltip.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @tooltip, notice: 'Tooltip was successfully updated.'
    else
      render :show
    end
  end

  def destroy
    tooltip = find_tooltip

    tooltip.destroy!
    tooltip.create_activity Activity::DESTROY, current_user

    redirect_to tooltips_path, notice: 'Tooltip was successfully deleted.'
  end

  private

    def find_tooltip
      Tooltip.find(params[:id])
    end

    def tooltip_params
      params.require(:tooltip).permit(:key, :scope, :text)
    end
end
