# coding: UTF-8
class ChangesController < ApplicationController

  def index

    @changes = Change.creations.paginate page: params[:page]
    respond_to do |format|
      format.atom {render(nothing: true)}
      format.html
    end
  end

  def show
    @change = Change.find params[:id]
  end

  def approve
    @change = Change.find params[:id]
    @change.taxon.approve!
    @change.update_attributes! approver_id: current_user.id, approved_at: Time.now
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end


  def undo
    @change = Change.find params[:id]
    # joe - once you haev the change id, find all transactions. For each transaction,
    # load a version, and undo the change
    Transaction.find_all_by_change_id(@change.id).each do |transaction|
      version = transaction.paper_trail_version
      if version.reify
        version.reify.save!
      else
        version.item.destroy
      end
    end

    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

end
