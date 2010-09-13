class RenameSeriesVolumeIssue < ActiveRecord::Migration
  def self.up
    rename_column :references, :issue, :series_volume_issue
  end

  def self.down
    rename_column :references, :series_volume_issue, :issue
  end
end
