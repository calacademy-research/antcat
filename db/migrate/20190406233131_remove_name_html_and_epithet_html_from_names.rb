class RemoveNameHtmlAndEpithetHtmlFromNames < ActiveRecord::Migration[5.2]
  def change
    remove_column :names, :name_html, :string
    remove_column :names, :epithet_html, :string
  end
end
