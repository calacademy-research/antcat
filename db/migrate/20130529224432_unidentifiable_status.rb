class UnidentifiableStatus < ActiveRecord::Migration
  def up
    Taxon.update_all 'unidentifiable = "1"', 'status = "unidentifiable"'
    remove_column :taxa, :unidentifiable
  end

  def down
    add_column :taxa, :unidentifiable, :boolean
    Taxon.update_all 'status = "unidentifiable"', 'unidentifiable = "1"'
  end
end
