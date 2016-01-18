class TooltipsController < ApplicationController
  before_action :set_tooltip, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_editor
  skip_before_filter :authenticate_editor, only: [:enabled_selectors]

  def index
    tooltips = Tooltip.all
    @grouped_tooltips = tooltips.group_by do |tooltip|
      main_namespace_of_key tooltip.key
    end
  end

  def show
  end

  def new
    @tooltip = Tooltip.new(params.permit(:selector))
    @referral=params[:referral]
  end

  def edit
    redirect_to action: :show
  end

  def create
    @tooltip = Tooltip.new(tooltip_params)
    if @tooltip.save
      if params[:referral] && params[:referral].length > 0
        redirect_to params[:referral]
      else
        redirect_to tooltip_path(@tooltip), notice: 'Tooltip was successfully created.'
      end
    else
      render :new
    end
  end

  def update

    respond_to do |format|
      if @tooltip.update_attributes tooltip_params
        format.html { redirect_to(@tooltip, notice: 'Tooltip was successfully updated.') }
        format.json { respond_with_bip(@tooltip) }
      else
        format.html { render action: :show }
        format.json { respond_with_bip(@tooltip) }
      end
    end


  end

  def destroy
    @tooltip.destroy
    respond_to do |format|
      format.html { redirect_to tooltips_url, notice: 'Tooltip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def enabled_selectors # TODO improve this
    json = Tooltip.enabled_selectors.pluck(:selector, :text, :id)
    render json: json # more "json" than json..
  end

  def render_missing_tooltips
    render json: {:show_missing_tooltips => current_user.is_superadmin?}
  end

  private
  def set_tooltip
    @tooltip = Tooltip.find params[:id]
  end

  def tooltip_params
    params.require(:tooltip).permit(
        :key, :text, :key_enabled, :selector, :selector_enabled)
  end

  def main_namespace_of_key key
    key.scan(/.*?(?=\.)/).first
  end
end
