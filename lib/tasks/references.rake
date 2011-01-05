desc 'Find duplicate references'
task :find_duplicate_references => :environment do
  DuplicateReferencesFinder.new(true).find_duplicates
end

