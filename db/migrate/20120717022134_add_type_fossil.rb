class AddTypeFossil < ActiveRecord::Migration
  def change
    add_column :taxa, :type_fossil, :boolean
  end
end
