class TooltipsController < ApplicationController
  before_action :set_tooltip, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_editor

  def index
    @tooltips = Tooltip.all
  end

  def show
  end

  def new
    @tooltip = Tooltip.new
  end

  def edit
    redirect_to action: :show
  end

  def create
    @tooltip = Tooltip.new(tooltip_params)
    if @tooltip.save
      redirect_to tooltip_path(@tooltip), notice: 'Tooltip was successfully created.'
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
        format.html { render action: "edit" }
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

  private
    def set_tooltip
      @tooltip = Tooltip.find params[:id]
    end

    def tooltip_params
      params.require(:tooltip).permit(:key, :text, :enabled, :selector, :selector_enabled)
    end
end
