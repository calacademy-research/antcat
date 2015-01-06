# coding: UTF-8
class ChangesController < ApplicationController

  def index
    foo = Change.creations.uniq
    @changes = Change.creations.uniq.paginate page: params[:page]


    respond_to do |format|
      format.atom { render(nothing: true) }
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
    change_id = params[:id]
    change_id_set = find_future_changes(change_id)
    change_id_set.each do |undo_this_change_id|
      undo_change undo_this_change_id
    end
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end


  #TODO joe: hook the undo warning dialog to an ajax call that hits
  # find_future_changes and warns that many things will be rolled back.

  private
  # given a version, retrurn the change record id
  def find_change_from_version version
    print "Version: " + version.id.to_s
    Transaction.find_by_paper_trail_version_id(version.id).change_id
  end

  def get_all_change_ids version
    new_version = version.next
    change_id = find_change_from_version(version).to_i
    if new_version == nil
      return SortedSet.new([change_id])
    else
      return (SortedSet.new([change_id]).merge(get_all_change_ids(new_version)))
    end
  end


  # Look up all future changes of this change, return change IDs in an array,
  # ordered most recent to oldest.
  # inclusive of the change passed as argument.
  def find_future_changes change_id
    # For each change, get all the transactions.
    # for each transaction, get the version.
    # for each version get the change record id.
    #   Add that change record id plus its timestamp to a hash list if it isn't in there already
    #   if there is a "future" version of this version, recurse above loop.
    # sort and return the change record list.
    # because we need to go through papertrail's version
    change = Change.find change_id
    change_ids = SortedSet.new
    change.paper_trail_versions.each do |version|
      change_ids.merge(get_all_change_ids(version))
    end
    change_ids.add(change_id.to_i)
  end

  def undo_change change_id
    change = Change.find change_id
    Taxon.transaction do
      #  Once you have the change id, find all transactions. For each transaction,
      # load a version, and undo the change
      Transaction.find_all_by_change_id(change.id).each do |transaction|
        version = transaction.paper_trail_version
        if version.reify
          version.reify.save!
        else
          version.item.destroy
        end
        transaction.delete
        version.delete
      end
      change.delete
    end
  end
end

# test notes:
# add two changes. Roll back the earlier change, ensure that the later change gets hit.
# change something in a notes field, ensure it shows up as "Change" and then undo it and ensure that it's gone
#   check database records for above.
# a-b-c case, undo, ensure we're back to original
# change something with children. Ensure they're hit. Undo it. Ensure they're moved back. verify with db to ensure this happened.
# add two changes. Roll back the earlier change, ensure that the warning dialog box comes up

# modify species b
# a - b - a' case
# modify species b
# undo first change to species b
# see what happens!

