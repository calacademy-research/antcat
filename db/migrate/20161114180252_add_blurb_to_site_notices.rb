class AddBlurbToSiteNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :site_notices, :blurb, :string
  end
end
