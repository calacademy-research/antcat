class ChangesController < ApplicationController
  before_action :authenticate_editor, except: [:index, :show, :unreviewed]
  before_action :authenticate_superadmin, only: [:approve_all]
  before_action :set_change, only: [:show, :approve]

  def index
    @changes = Change.order(created_at: :desc).paginate(page: params[:page], per_page: 8)
  end

  def show
  end

  def unreviewed
    @changes = Change.waiting.order(created_at: :desc).paginate(page: params[:page], per_page: 8)
  end

  # TODO handle error, if any.
  def approve
    @change.approve current_user
    redirect_to changes_path, notice: "Approved change."
  end

  # TODO handle error, if any.
  def approve_all
    Change.approve_all current_user
    redirect_to changes_path, notice: "Approved all changes."
  end

  private
    def set_change
      @change = Change.find params[:id]
    end
end
