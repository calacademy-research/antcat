class MakeReferenceTaxtText < ActiveRecord::Migration
  def up
    change_column :updates, :before, :text
    change_column :updates, :after, :text
  end

  def down
    change_column :updates, :before, :string
    change_column :updates, :after, :string
  end
end
