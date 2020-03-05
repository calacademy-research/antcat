class PageOriginToScope < ActiveRecord::Migration[4.2]
  def change
    rename_column :tooltips, :page_origin, :scope
  end
end
