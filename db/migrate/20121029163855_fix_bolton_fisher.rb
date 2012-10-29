class FixBoltonFisher < ActiveRecord::Migration
  def up
    missing_reference = Taxon.find_by_name('Simopone miniflava').protonym.authorship.reference
    replacement_reference = Reference.find_by_key_cache 'Bolton & Fisher, 2012'
    missing_reference.replace_with replacement_reference
  end
end
