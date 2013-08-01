class ChangesController < ApplicationController

  def index
    @changes = Change.creations.paginate page: params[:page]
  end

  def show
    @change = Change.find params[:id]
  end

  def approve
    @change = Change.find params[:id]
    @change.taxon.approve!
    @change.update_attributes! approver_id: current_user.id, approved_at: @change.updated_at
    redirect_to changes_path
  end

end
