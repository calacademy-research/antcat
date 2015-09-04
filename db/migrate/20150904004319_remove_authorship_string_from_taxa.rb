class RemoveAuthorshipStringFromTaxa < ActiveRecord::Migration
  def change
    remove_column :taxa, :authorship_string
  end
end
