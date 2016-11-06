class ChangesController < ApplicationController
  before_action :authenticate_editor, except: [:index, :show, :unreviewed]
  before_action :authenticate_superadmin, only: [:approve_all]
  before_action :set_change, only: [:show, :approve, :undo,
    :destroy, :undo_items]

  def index
    @changes = Change.order(created_at: :desc).paginate(page: params[:page], per_page: 8)
  end

  def show
  end

  def unreviewed
    @changes = Change.waiting.order(created_at: :desc).paginate(page: params[:page], per_page: 8)
  end

  def approve
    @change.approve current_user
    redirect_to changes_path, notice: "Approved change."
  end

  def approve_all
    Change.approve_all current_user
    redirect_to changes_path, notice: "Approved all changes."
  end

  def undo
    @change.undo
    render json: { success: true }
  end

  # Return information about all the taxa that would be hit if we were to
  # hit "undo". Includes current taxon. For display.
  def undo_items
    changes = @change.undo_items
    render json: changes, status: :ok
  end

  private
    def set_change
      @change = Change.find params[:id]
    end
end
