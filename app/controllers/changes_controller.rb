# coding: UTF-8
class ChangesController < ApplicationController

  def index
    @changes = Change.creations.uniq.paginate page: params[:page], per_page: 2


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
        versions.concat(find_all_versions_for_change(undo_this_change_id))
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

  def destroy
    destroy_id = params[:id]

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
    if (change_id_str == nil)
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
      versions << PaperTrail::Version.find(transaction.paper_trail_version.id)
    end
    versions
  end

  def undo_versions versions
    versions.sort_by &:id
    versions.reverse!

    Taxon.paper_trail_off!
    versions.each do |version|
      if version.reify do
        taxon = version.reify
        review_state = taxon[:review_state]
        # review_state got moved to taxon_states.
        # This makes it backwards compatible - if the variable is defined when we re-load the taxon,
        # spool it out to the new table and remove it from taxon.
        unless review_state.nil? do
          taxon[:review_state]=nil
          taxon.taxon_state.review_state = review_state
        end
          taxon.save!
        else
          version.item.destroy
        end
        version.delete
      end
        Taxon.paper_trail_on!
      end
    end
  end
end






