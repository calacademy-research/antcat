class RemoveReferencesTexts < ActiveRecord::Migration
  def up
    drop_table :references_texts rescue nil
  end

  def down
  end
end
