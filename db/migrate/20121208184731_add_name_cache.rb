class AddNameCache < ActiveRecord::Migration
  def up
    add_column :taxa, :name_cache, :string rescue nil
    add_column :taxa, :name_html_cache, :string rescue nil

    Taxon.all.each do |taxon|
      taxon.update_attributes name_cache: taxon.name.name, name_html_cache: taxon.name.name_html
    end
  end

  def down
    remove_column :taxa, :name_cache
    remove_column :taxa, :name_html_cache
  end
end
