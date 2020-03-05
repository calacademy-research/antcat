class RemoveBlurbFromSiteNotices < ActiveRecord::Migration[4.2]
  def change
    remove_column :site_notices, :blurb, :string
  end
end
