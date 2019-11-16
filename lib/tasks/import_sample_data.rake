# Useful if you want to locally experiment with the code after cloning the git repo.
# Import the sample data by running `bundle exec rake antcat:db:import_sample_data`.
#
# If you want to develop locally with real data, please contact AntCat to request a database dump.

namespace :antcat do
  namespace :db do
    desc "Import sample data"
    task import_sample_data: [:environment] do
      require 'factory_bot'
      require 'sunspot_test'

      ENV["RAILS_ENV"] ||= 'development'
      SunspotTest.stub

      puts "Warning: this command may corrupt the '#{ENV['RAILS_ENV']}' database. Enter 'y' to continue:"
      abort 'Aborting.' unless STDIN.gets.chomp == "y"

      puts "Creating taxa..."
      create :family # Formicidae.

      antcatinae = create :subfamily, name_string: 'Antcatinae'
      antcatini = create :tribe, name_string: 'Antcatini', subfamily: antcatinae

      # A bunch of species.
      pseudoantcatia = create :genus, name_string: 'Pseudoantcatia', tribe: antcatini
      %w[africana maximus indicus celebensis columbi].each do |species|
        create :species, name_string: "Pseudoantcatia #{species}", genus: pseudoantcatia
      end

      # A bunch of subspecies.
      antcatia = create :genus, name_string: 'Antcatia', tribe: antcatini
      antcatia_tigris = create :species, name_string: 'Antcatia tigris', genus: antcatia
      %w[corbetti jacksoni sumatrae].each do |subspecies|
        create :subspecies, name_string: "Antcatia tigris #{subspecies}",
          subfamily: antcatinae,
          genus: antcatia,
          species: antcatia_tigris
      end

      # Fossil subfamily.
      create :subfamily, :fossil, name_string: 'Paraantcatinae'

      puts "Creating user..."
      User.create!(email: 'editor@example.com', name: 'Test Editor', password: 'secret123', editor: true, superadmin: true)

      puts "Successfully imported sample data."
    end
  end
end
