class AddPageOrigin < ActiveRecord::Migration[4.2]
  def change
    add_column :tooltips, :page_origin, :string
  end
end
