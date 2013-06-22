class DestroyOrphanProtonyms < ActiveRecord::Migration
  def up
    Protonym.destroy_orphans
  end
end
