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
end
