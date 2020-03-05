class NonconformingName < ActiveRecord::Migration[4.2]
  def change
    add_column :names, :nonconforming_name, :boolean
  end
end
