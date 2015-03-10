# coding: UTF-8
class ChangesController < ApplicationController

  def index
    @changes = Change.creations.paginate page: params[:page], per_page: 8


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
    if (@change.taxon.nil?)
      # This case is for approving a delete
      taxon_id = @change.user_changed_taxon_id
      taxon_state = TaxonState.find_by taxon_id: taxon_id
      taxon_state.review_state = "approved"
      taxon_state.save!
    else
      @change.taxon.approve!
      @change.update_attributes! approver_id: current_user.id, approved_at: Time.now
    end
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end


  def undo
    #  Once you have the change id, find all future changes
    # that touch this same item set.
    # find all versions, and undo the change
    # Sort to undo changes most recent to oldest
    change_id = params[:id]
    change_id_set = find_future_changes(change_id)
    versions = SortedSet.new
    items = SortedSet.new
    Taxon.transaction do
      change_id_set.each do |undo_this_change_id|
        begin
          # could be already undone.
          cur_change = Change.find(undo_this_change_id)
        rescue ActiveRecord::RecordNotFound
          next
        end
        cur_change.versions.each do |cur_version|
          versions.add(cur_version)
        end
        cur_change.delete
      end
      undo_versions versions
    end
    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end


  def destroy
    destroy_id = params[:id]
    raise NotImplementedError

    json = {success: true}.to_json
    render json: json, content_type: 'text/html'
  end

  # reutrn information about all the taxa that would be hit if we were to
  # hit "undo". Includes current taxon. For display.
  def undo_items
    change_id = params[:id]
    change_id_set = find_future_changes(change_id)
    changes = []
    change_id_set.each do |cur_change_id|
      begin
        # could be already undone.
        cur_change = Change.find(cur_change_id)
      rescue ActiveRecord::RecordNotFound
        next
      end
      # Could get cute and report exactly what was changed about any given taxon
      # For now, just report a change to the taxon in question.
      cur_taxon = cur_change.get_most_recent_valid_taxon
      cur_user = cur_change.changed_by
      changes.append(name: cur_taxon.name.to_s,
                     change_type: cur_change.change_type,
                     change_timestamp: cur_change.created_at.strftime("%B %d, %Y"),
                     user_name: cur_user.name)
      # This would be a good place to warn from if we find that we can't undo
      # something about a taxa.
    end
    render json: changes.to_json, status: :ok
  end

  private

  # Note that because of schema change, we can't do this for changes that don't
  # have an extracted taxon_state.
  def undo_versions versions
    versions.reverse_each do |version|
      if 'create' == version.event
        klass = version.item_type.constantize
        item = klass.find(version.item_id)
        item.delete
      else
        item = version.previous.reify
        begin
          # because we validate on things like the genus being present, and if we're doing an entire change set,
          # it might not be!
          unless (item.nil?)
            item.save!(:validate => false)
          end
        rescue ActiveRecord::RecordInvalid => error

          puts("=========Reify failure:" + error.to_s + " version item_type = " + version.item_type.to_s)
          raise error
        end
      end
    end
  end


  # Starting at a given version (which can reference any of a set of objects), it iterates forwards and
  # returns all changes that created future versions of said object. Exclusive of
  # the passed in object.
  def get_future_change_ids version
    new_version = version.next
    change_id = version.change_id
    if (change_id == nil)
      return SortedSet.new
    end
    if new_version == nil
      return SortedSet.new([change_id])
    else
      return (SortedSet.new([change_id]).merge(get_future_change_ids(new_version)))
    end
  end


  # Look up all future changes of this change, return change IDs in an array,
  # ordered most recent to oldest.
  # inclusive of the change passed as argument.
  def find_future_changes change_id

    # This returns changes that touch future versions of
    # all paper trail type items.

    # For each change, get all the versions.
    # for each version get the change record id.
    #   Add that change record id plus its timestamp to a hash list if it isn't in there already
    #   if there is a "future" version of this version, recurse above loop.
    # sort and return the change record list.
    # because we need to go through papertrail's version
    change = Change.find change_id
    change_ids = SortedSet.new
    change_ids.add(change_id.to_i)
    change.versions.each do |version|
      change_ids.merge(get_future_change_ids(version))
    end
    change_ids
  end


end







