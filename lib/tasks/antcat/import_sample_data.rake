# Useful if you want to experiment locally with the code after cloning the git repo.
# If you want to develop locally with real data, please contact AntCat to request a database dump.

namespace :antcat do
  desc "Import sample data"
  task import_sample_data: [:environment] do
    require 'factory_bot'
    require 'sunspot_test'

    ENV["RAILS_ENV"] ||= 'development'
    SunspotTest.stub

    puts "Warning: this command may corrupt the '#{ENV['RAILS_ENV']}' database. Enter 'y' to continue:"
    abort 'Aborting.' unless STDIN.gets.chomp == "y"

    create :family # Formicidae, the family of all ants.
    antcatinae = create :subfamily, name_string: 'Antcatinae'
    antcatini = create :tribe, name_string: 'Antcatini', subfamily: antcatinae

    # A bunch of species and subspecies.
    antcatia = create :genus, name_string: 'Antcatia', tribe: antcatini
    antcatia_tigris = create :species, name_string: 'Antcatia tigris', genus: antcatia
    %w[corbetti jacksoni sumatrae].each do |subspecies|
      create :subspecies, name_string: "Antcatia tigris #{subspecies}",
        subfamily: antcatinae, genus: antcatia, species: antcatia_tigris
    end

    User.create!(email: 'editor@example.com', name: 'Test Editor', password: 'secret123', editor: true, superadmin: true)
    puts "Created taxa and user."
  end
end
