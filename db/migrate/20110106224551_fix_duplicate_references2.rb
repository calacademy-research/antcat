class FixDuplicateReferences2 < ActiveRecord::Migration
  def self.up
    DuplicateReference.merge 131791, 131775
  end

  def self.down
  end
end
