class AddForwardReferenceFossil < ActiveRecord::Migration
  def up
    add_column :forward_references, :fossil, :boolean
  end

  def down
    remove_column :forward_references, :fossil
  end
end
