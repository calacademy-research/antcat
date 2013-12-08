# coding: UTF-8
require 'factory_girl'

desc "Create a new genus that is waiting to be approved"
task create_approved_taxon: :environment do
  Taxon.find_by_name('Wildensi').delete rescue nil
  user = User.find_by_email 'mark@mwilden.com'
  taxon = create_taxon_version_and_change :waiting, user
  taxon.update_attributes! name: create_name('Wildensi')
end

desc 'Update current valid taxa'
task :update_current_valid_taxa => :environment do
  taxa = Taxon.where status: 'synonym'
  Progress.init true, taxa.count
  synonyms_without_current_valid_taxon = 0
  for synonym in taxa
    Progress.tally_and_show_progress 1000
    synonym.update_current_valid_taxon
    unless synonym.reload.current_valid_taxon.present?
      puts synonym.name.name
      synonyms_without_current_valid_taxon += 1
    end
  end
  Progress.show_results
  Progress.show_count synonyms_without_current_valid_taxon, Progress.processed_count, "synonyms ended up without a current valid taxon"
end
