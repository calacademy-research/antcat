class AddCitationFieldsToRefs < ActiveRecord::Migration
  def self.up
    add_column :refs, :journal_short_title, :string
    add_column :refs, :series, :string
    add_column :refs, :volume, :string
    add_column :refs, :issue, :string
    add_column :refs, :start_page, :string
    add_column :refs, :end_page, :string
    add_column :refs, :place, :string
    add_column :refs, :publisher, :string
    add_column :refs, :pagination, :string
    add_column :refs, :kind, :string
  end

  def self.down
    remove_column :refs, :journal_short_title
    remove_column :refs, :series
    remove_column :refs, :volume
    remove_column :refs, :issue
    remove_column :refs, :start_page
    remove_column :refs, :end_page
    remove_column :refs, :place
    remove_column :refs, :publisher
    remove_column :refs, :pagination
    remove_column :refs, :kind
  end
end
