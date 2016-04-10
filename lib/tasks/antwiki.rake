namespace :antwiki do

  desc "Compare AntWiki's file of valid taxa against AntCat"
  task compare_valid: :environment do
    Antwiki.compare_valid true
  end

end
