class AddReasonMissing < ActiveRecord::Migration
  def up
    add_column :references, :reason_missing, :string
  end

  def down
    remove_column :references, :reason_missing
  end
end
