class TooltipsController < ApplicationController
  before_action :authenticate_superadmin, only: [:destroy]
  before_action :ensure_user_is_at_least_helper, except: [:index]
  before_action :set_tooltip, only: [:show, :edit, :update, :destroy]

  def index
    @grouped_tooltips = Tooltip.order(:key).group_by(&:scope)
  end

  def show
  end

  def new
    @tooltip = Tooltip.new
    @tooltip.key = params[:key]
  end

  def edit
    redirect_to action: :show
  end

  def create
    @tooltip = Tooltip.new tooltip_params
    if @tooltip.save
      redirect_to @tooltip, notice: 'Tooltip was successfully created.'
    else
      render :new
    end
  end

  def update
    if @tooltip.update tooltip_params
      redirect_to @tooltip, notice: 'Tooltip was successfully updated.'
    else
      render :show
    end
  end

  def destroy
    @tooltip.destroy
    redirect_to tooltips_path, notice: 'Tooltip was successfully deleted.'
  end

  private

    def set_tooltip
      @tooltip = Tooltip.find params[:id]
    end

    def tooltip_params
      params.require(:tooltip).permit(:key, :scope, :text)
    end
end
