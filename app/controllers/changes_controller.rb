# coding: UTF-8
class ChangesController < ApplicationController

  def index
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
    #  Once you have the change id, find all transactions. For each transaction,
    # load a version, and undo the change
    # Sort to undo changes most recent to oldest
    change_id = params[:id]
    change = Change.find(change_id)
    change_id_set = find_future_changes(change_id)
    versions = []
    Taxon.transaction do
      change_id_set.each do |undo_this_change_id|
        versions.concat( find_all_versions_for_change(undo_this_change_id))
      end
      undo_versions versions
      change.delete
      change.transactions.each do |transaction|
        transaction.delete
      end
    end
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

  # reutrn information about all the taxa that would be hit if we were to
  # hit "undo". Includes current taxon.
  def undo_items
    change_id = params[:id]
    change = Change.find(change_id)
    change_id_set = find_future_changes(change_id)
    changes = []
    change_id_set.each do |cur_change_id|
      cur_change = Change.find(cur_change_id)
      cur_taxon = cur_change.taxon
      cur_transaction = cur_change.transactions.first
      cur_user = User.find (cur_transaction.paper_trail_version.whodunnit)
      changes.append(name: cur_taxon.name.to_s,
                     change_type: cur_change.change_type,
                     change_timestamp: cur_change.created_at.strftime("%B %d, %Y"),
                     user_name: cur_user.name)
    end
    render json: changes.to_json, status: :ok
  end


  #TODO joe: hook the undo warning dialog to an ajax call that hits
  # find_future_changes and warns that many things will be rolled back.

  private
  # given a version, retrurn the change record id
  # For non-legacy undo, this should always return a value.
  # However, older updates don't necessarily have an associated transaction record.
  def find_change_from_version version
    transaction = Transaction.find_by_paper_trail_version_id(version.id)
    unless transaction.nil?
      return transaction.change_id
    else
      return nil
    end

  end

  def get_all_change_ids version
    new_version = version.next
    change_id_str = find_change_from_version(version)
    if(change_id_str == nil)
      return SortedSet.new
    end
    change_id = change_id_str.to_i
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

  def find_all_versions_for_change change_id
    versions=[]
    Transaction.find_all_by_change_id(change_id).each do |transaction|
      versions << Version.find(transaction.paper_trail_version)
    end
    versions
  end

  def undo_versions versions
    versions.sort_by &:id
    versions.reverse!
    # Some side effect of restoring this created a change record that hosed our world pretty good.
    Taxon.paper_trail_off
    versions.each do |version|
      if version.reify
        version.reify.save!
      else
        version.item.destroy
      end
      version.delete
    end
    Taxon.paper_trail_on


  end
end






