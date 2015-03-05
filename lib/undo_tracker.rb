require 'paper_trail'
module UndoTracker

  def setup_change change_type
    change = Change.new
    change.change_type = change_type
    change.user_changed_taxon_id = @taxon.id
    change.save!
    RequestStore.store[:current_change_id] = change.id
    change
  end

  def get_current_change_id
    RequestStore.store[:current_change_id]
  end


end