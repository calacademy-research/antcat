class RemoveBlurbFromSiteNotices < ActiveRecord::Migration
  def change
    remove_column :site_notices, :blurb, :string
  end
end
