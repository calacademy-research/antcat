class ChangeSourceReferenceType < ActiveRecord::Migration
  def self.up
    Reference.update_all 'source_reference_type = "Ward::Reference"', 'source_reference_type = "WardReference"'
  end

  def self.down
  end
end
