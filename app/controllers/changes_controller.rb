class ChangesController < ApplicationController
  include UndoTracker

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
    approve_change @change
    redirect_to changes_path, notice: "Approved change."
  end

  def approve_all
    count = TaxonState.where(review_state: 'waiting').count

    Feed::Activity.without_tracking do
      TaxonState.where(review_state: 'waiting').each do |taxon_state|
        Change.where(user_changed_taxon_id: taxon_state.taxon_id).each do |change|
          approve_change change
        end
      end
    end
    Feed::Activity.create_activity :approve_all_changes, count: count

    redirect_to changes_path, notice: "Approved all changes."
  end

  # TODO move to model
  def undo
    # Once you have the change id, find all future changes
    # that touch this same item set.
    # find all versions, and undo the change
    # Sort to undo changes most recent to oldest
    Feed::Activity.without_tracking do
      clear_change
      change_id_set = find_future_changes @change
      versions = SortedSet[]
      items = SortedSet[]
      Taxon.transaction do
        change_id_set.each do |undo_this_change_id|
          begin
            # could be already undone.
            current_change = Change.find undo_this_change_id
          rescue ActiveRecord::RecordNotFound
            next
          end
          versions.merge current_change.versions
          current_change.delete
        end
        undo_versions versions
      end
    end
    @change.create_activity :undo_change

    json = { success: true }
    render json: json
  end

  def destroy
    raise NotImplementedError

    json = { success: true }
    render json: json
  end

  # return information about all the taxa that would be hit if we were to
  # hit "undo". Includes current taxon. For display.
  def undo_items
    change_id_set = find_future_changes @change
    changes = []
    change_id_set.each do |current_change_id|
      begin
        # could be already undone.
        current_change = Change.find current_change_id
      rescue ActiveRecord::RecordNotFound
        next
      end
      # Could get cute and report exactly what was changed about any given taxon
      # For now, just report a change to the taxon in question.
      current_taxon = current_change.most_recent_valid_taxon
      current_user = current_change.changed_by
      changes.append name: current_taxon.name.to_s,
                     change_type: current_change.change_type,
                     change_timestamp: current_change.created_at.strftime("%B %d, %Y"),
                     user_name: current_user.name
      # This would be a good place to warn from if we find that we can't undo
      # something about a taxa.
    end
    render json: changes, status: :ok
  end

  private
    def set_change
      @change = Change.find params[:id]
    end

    # TODO move to model
    def approve_change change
      taxon_id = change.user_changed_taxon_id
      taxon_state = TaxonState.find_by(taxon: taxon_id)
      return if taxon_state.review_state == "approved"

      if change.taxon
        change.taxon.approve!
        change.update_attributes! approver: current_user, approved_at: Time.now
      else
        # This case is for approving a delete
        # TODO? approving deletions doesn't set `approver` or `approved_at`.
        taxon_state.review_state = "approved"
        taxon_state.save!
      end

      Feed::Activity.with_tracking { change.create_activity :approve_change }
    end

    # Note that because of schema change, we can't do this for changes that don't
    # have an extracted taxon_state.
    def undo_versions versions
      versions.reverse_each do |version|
        if version.event == 'create'
          klass = version.item_type.constantize
          item = klass.find version.item_id
          item.delete
        else
          item = version.reify
          unless item
            raise "failed to reify version: #{version.id} referencing change: #{version.change_id}"
          end
          begin
            # because we validate on things like the genus being present, and if we're doing an entire change set,
            # it might not be!
            item.save! validate: false if item
          rescue ActiveRecord::RecordInvalid => error
            puts "=========Reify failure: #{error} version item_type =  #{version.item_type}"
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
      return SortedSet[] unless change_id

      if new_version
        SortedSet[change_id].merge get_future_change_ids(new_version)
      else
        SortedSet[change_id]
      end
    end

    # Look up all future changes of this change, return change IDs in an array,
    # ordered most recent to oldest.
    # inclusive of the change passed as argument.
    def find_future_changes change
      # This returns changes that touch future versions of
      # all paper trail type items.

      # For each change, get all the versions.
      # for each version get the change record id.
      #   Add that change record id plus its timestamp to a hash list if it isn't in there already
      #   if there is a "future" version of this version, recurse above loop.
      # sort and return the change record list.
      # because we need to go through papertrail's version
      change_ids = SortedSet[change.id]
      change.versions.each do |version|
        change_ids.merge get_future_change_ids(version)
      end
      change_ids
    end
end
