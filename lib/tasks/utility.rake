# coding: UTF-8
desc "Extract original combinations"
task :extract_original_combinations => :environment do
  Taxon.extract_original_combinations true
end
