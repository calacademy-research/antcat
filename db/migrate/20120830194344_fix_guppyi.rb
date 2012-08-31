class FixGuppyi < ActiveRecord::Migration
  def up
    guppyi = Taxon.find_by_name('Camponotus guppyi') or raise
    correct_reference = Reference.find_by_bolton_key_cache('Mann 1919') or raise
    guppyi.protonym.authorship.update_attribute :reference, correct_reference
  end

  def down
  end
end
