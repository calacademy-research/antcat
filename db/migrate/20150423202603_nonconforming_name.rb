class NonconformingName < ActiveRecord::Migration
  def change
    add_column :names, :nonconforming_name, :boolean
  end
end
