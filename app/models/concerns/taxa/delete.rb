# TODO add `before_destroy :check_not_referenced`, but allow suppressing it.

module Taxa::Delete
  extend ActiveSupport::Concern

  def delete_with_state!
    Taxon.transaction do
      # Bit of a hack; this is a new table which may lack the depth of other tables.
      # Creation doesn't add a record, so you can't "step back to" a valid version.
      # doing touch_with_version (creeate a fallback point) in the migration makes an
      # enourmous and unnecessary pile of these.
      taxon_state.paper_trail.touch_with_version if taxon_state.versions.empty?

      taxon_state.deleted = true
      taxon_state.review_state = 'waiting'
      taxon_state.save
      destroy!
    end
  end

  def delete_impact_list
    get_taxon_children_recur(self).concat([self])
  end

  def delete_taxon_and_children
    Feed.without_tracking do
      Taxon.transaction do
        UndoTracker.setup_change self, :delete
        delete_taxon_children self
        delete_with_state!
      end
    end
    create_activity :destroy
  end

  private
    # TODO see Subfamily#children for a known bug.
    def get_taxon_children_recur taxon
      ret_val = []
      taxon.children.each do |child|
        ret_val.concat [child]
        ret_val.concat get_taxon_children_recur child
      end
      ret_val
    end

    def delete_taxon_children taxon
      taxon.children.each do |child|
        child.delete_with_state!
        delete_taxon_children child
      end
    end
end
