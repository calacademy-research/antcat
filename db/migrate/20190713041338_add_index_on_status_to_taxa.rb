class AddIndexOnStatusToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_index :taxa, :status
  end
end
