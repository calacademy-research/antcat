class AddDisplayToTaxon < ActiveRecord::Migration[4.2]
  def change
    add_column :taxa, :display, :boolean, default: true
  end
end
