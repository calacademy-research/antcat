class AddDisplayToTaxon < ActiveRecord::Migration
  def change
    add_column :taxa, :display, :boolean, default: true
  end
end
