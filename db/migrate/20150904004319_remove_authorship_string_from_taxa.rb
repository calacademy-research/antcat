class RemoveAuthorshipStringFromTaxa < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxa, :authorship_string
  end
end
