module Taxa::Delete
  extend ActiveSupport::Concern

  def delete_with_state!
    Taxon.transaction do
      taxon_state = self.taxon_state
      # Bit of a hack; this is a new table which may lack the depth of other tables.
      # Creation doesn't add a record, so you can't "step back to" a valid version.
      # doing touch_with_version (creeate a fallback point) in the migration makes an
      # enourmous and unnecessary pile of these.
      if taxon_state.versions.empty?
        taxon_state.touch_with_version
      end

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
    Taxon.transaction do
      change = setup_change :delete
      delete_taxon_children self

      delete_with_state!
      change.user_changed_taxon_id = id
    end
  end

  private
    def get_taxon_children_recur taxon
      ret_val = []
      taxon.children.each do |c|
        ret_val.concat [c]
        ret_val.concat get_taxon_children_recur c
      end
      ret_val
    end

    def delete_taxon_children taxon
      taxon.children.each do |c|
        c.delete_with_state!
        delete_taxon_children c
      end
    end
end
