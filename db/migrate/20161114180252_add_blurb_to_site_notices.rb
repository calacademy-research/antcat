class AddBlurbToSiteNotices < ActiveRecord::Migration
  def change
    add_column :site_notices, :blurb, :string
  end
end
