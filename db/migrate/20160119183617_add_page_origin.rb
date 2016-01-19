class AddPageOrigin < ActiveRecord::Migration
  def change
    add_column :tooltips, :page_origin, :string
  end
end
