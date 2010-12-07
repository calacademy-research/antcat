class ChangeBoltonDateToNote < ActiveRecord::Migration
  def self.up
    rename_column :bolton_references, :date, :note
  end

  def self.down
    rename_column :bolton_references, :note, :date
  end
end
