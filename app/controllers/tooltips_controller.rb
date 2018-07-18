class TooltipsController < ApplicationController
  before_action :authenticate_editor
  before_action :set_tooltip, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_editor, only: :enabled_selectors

  def index
    @grouped_tooltips = Tooltip.order(:key).group_by(&:scope)
  end

  def show
    @referral = request.referer
  end

  def new
    @tooltip = Tooltip.new params.permit(:selector)
    @tooltip.selector_enabled = true
    @tooltip.key = params[:key]
    @tooltip.scope = get_page_from_url request.referer
    @referral = request.referer
  end

  def edit
    redirect_to action: :show
  end

  def create
    @tooltip = Tooltip.new tooltip_params
    if @tooltip.save
      if params[:referral] && params[:referral].size > 0
        redirect_to params[:referral] # joe dis broke
      else
        redirect_to tooltip_path(@tooltip), notice: 'Tooltip was successfully created.'
      end
    else
      render :new
    end
  end

  def update
    if @tooltip.update tooltip_params
      if params[:referral] && params[:referral].size > 0
        redirect_to params[:referral]
        return
      end

      redirect_to @tooltip, notice: 'Tooltip was successfully updated.'
    else
      render :show
    end
  end

  def destroy
    @tooltip.destroy
    redirect_to tooltips_path, notice: 'Tooltip was successfully deleted.'
  end

  def enabled_selectors
    scope = get_page_from_url request.referer
    json = Tooltip.enabled_selectors.where(scope: scope).pluck(:selector, :text, :id)
    render json: json
  end

  def render_missing_tooltips
    render json: { show_missing_tooltips: session[:show_missing_tooltips] }
  end

  def toggle_tooltip_helper
    session[:show_missing_tooltips] = !session[:show_missing_tooltips]
    redirect_to tooltips_path
  end

  private

    def get_page_from_url url
      return unless url

      doomed = url.clone
      doomed.slice! root_url
      doomed.split('/').first
    end

    def set_tooltip
      @tooltip = Tooltip.find params[:id]
    end

    def tooltip_params
      params.require(:tooltip).permit :key, :scope, :text,
        :key_enabled, :selector, :selector_enabled
    end
end
