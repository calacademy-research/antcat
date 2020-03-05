class AddDoiToReference < ActiveRecord::Migration[4.2]
  def change
    add_column :references, :doi, :string
  end
end
