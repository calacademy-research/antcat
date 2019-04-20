class ChangesController < ApplicationController
  before_action :ensure_can_edit_catalog, except: [:index, :show, :unreviewed]
  before_action :authenticate_superadmin, only: :approve_all
  before_action :set_change, only: [:show, :approve]

  def index
    @changes = Change.includes_associated.order(created_at: :desc).paginate(page: params[:page])
  end

  def show
  end

  def unreviewed
    @changes = Change.waiting.includes_associated.order(created_at: :desc).paginate(page: params[:page])
  end

  def approve
    @change.approve current_user
    redirect_back fallback_location: changes_path, notice: "Approved change."
  end

  def approve_all
    Change.approve_all current_user
    redirect_to changes_path, notice: "Approved all changes."
  end

  private

    def set_change
      @change = Change.find params[:id]
    end
end
