class RemoveCommas < ActiveRecord::Migration
  def up
    Progress.init true, Reference.count
    add_column :references, :key_cache_no_commas, :string rescue nil
    Reference.all.each do |reference|
      Progress.tally_and_show_progress 100
      next unless reference.key_cache?
      key_cache_no_commas = reference.key_cache
      key_cache_no_commas.gsub! /,/, ''
      reference.update_attributes! key_cache_no_commas: key_cache_no_commas
    end
    Progress.show_results
  end

  def down
  end
end
