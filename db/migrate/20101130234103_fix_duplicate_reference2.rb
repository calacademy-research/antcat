class FixDuplicateReference2 < ActiveRecord::Migration
  def self.up
    duplicate = Reference.find_by_year_and_pagination_and_cite_code 2007, '1-53', nil
    original = Reference.find_by_year_and_pagination_and_cite_code 2007, '1-53', '96-1629'
    nester = Reference.find_by_nested_reference_id duplicate.id
    nester.update_attribute :nested_reference_id, original.id
    duplicate.destroy
  end

  def self.down
  end
end
