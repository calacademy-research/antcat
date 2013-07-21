class RemoveNullChanges < ActiveRecord::Migration
  def up
    Change.where(paper_trail_version_id: nil).destroy_all
  end
end
