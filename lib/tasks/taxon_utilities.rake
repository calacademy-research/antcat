# coding: UTF-8
require 'factory_girl'

desc "Create a new genus that is waiting to be approved"
task create_approved_taxon: :environment do
  Taxon.find_by_name('Wildensi').destroy rescue nil
  user = User.find_by_email 'mark@mwilden.com'
  taxon = create_taxon_version_and_change :waiting, user
  taxon.update_attributes! name: create_name 'Wildensi'
end
