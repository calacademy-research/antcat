desc "Validate and report on the database"
task :vlad => :environment do
  Vlad.idate true
end
