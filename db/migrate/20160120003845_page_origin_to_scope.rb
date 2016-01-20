class PageOriginToScope < ActiveRecord::Migration
  def change
    rename_column :tooltips, :page_origin, :scope
  end
end
