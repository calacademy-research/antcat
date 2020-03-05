class RemovePossessAndCiteCodeFromReferences < ActiveRecord::Migration[4.2]
  def change
    remove_column :references, :cite_code, :string
    remove_column :references, :possess, :string
  end
end
