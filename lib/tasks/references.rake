desc 'Find duplicate references'
task :find_duplicate_references => :environment do
  DuplicateReferenceFinder.new(true).find_duplicates
end

