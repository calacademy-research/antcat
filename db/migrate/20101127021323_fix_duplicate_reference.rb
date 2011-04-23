class FixDuplicateReference < ActiveRecord::Migration
  def self.up
    # author name fixes resulted in finding a duplicate reference
    duplicate = Reference.find_by_year_and_pagination_and_cite_code 1995, '87-105', nil
    original = Reference.find_by_year_and_pagination_and_cite_code 1995, '87-105', '8321'
    nester = Reference.find_by_nested_reference_id duplicate.id
    nester.update_attribute :nested_reference_id, original.id
    duplicate.destroy
  end

  def self.down
  end
end
