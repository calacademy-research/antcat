class AddDoiToReference < ActiveRecord::Migration
  def change
    add_column :references, :doi, :string
  end
end
