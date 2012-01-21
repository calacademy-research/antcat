class AddReferencesTaxt < ActiveRecord::Migration
  def up
    add_column :taxa, :references_taxt, :text
  end

  def down
    remove_column :taxa, :references_taxt
  end
end
