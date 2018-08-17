# Useful if you want to locally experiment with the code after cloning the git repo.
# Import the sample data by running `bundle exec rake antcat:db:import_sample_data`.
#
# If you want to develop locally with real data, please contact AntCat
# to request a database dump.

namespace :antcat do
  namespace :db do
    desc "Import sample data"
    task import_sample_data: [:environment] do
      require 'factory_bot'
      require 'sunspot_test'

      ENV["RAILS_ENV"] ||= 'development'
      SunspotTest.stub

      puts "Warning: this command may corrupt the '#{ENV['RAILS_ENV']}' " +
        "database. Enter 'y' to continue:"
      abort 'Aborting.' unless STDIN.gets.chomp == "y"

      puts "Creating taxa..."
      create :family # Formicidae.

      antcatinae = create_subfamily 'Antcatinae'
      antcatini = create_tribe 'Antcatini', subfamily: antcatinae

      # a bunch of species
      pseudoantcatia = create_genus 'Pseudoantcatia', tribe: antcatini
      %w[africana maximus indicus celebensis columbi].each do |species|
        create_species "Pseudoantcatia #{species}", genus: pseudoantcatia
      end

      # a bunch of subspecies
      antcatia = create_genus 'Antcatia', tribe: antcatini
      antcatia_tigris = create_species 'Antcatia tigris', genus: antcatia
      %w[corbetti jacksoni sumatrae].each do |subspecies|
        create_subspecies "Antcatia tigris #{subspecies}",
          subfamily: antcatinae,
          genus: antcatia,
          species: antcatia_tigris
      end

      # fossil genus
      tactania = create_genus 'Tactania', tribe: antcatini, fossil: true
      %w[sisneopmos sisneuhsnihs silatneiro snorfinalpbus].each do |species|
        create_species "Tactania #{species}", genus: tactania, fossil: true
      end

      # fossil subfamily
      paraantcatinae = create_subfamily 'Paraantcatinae'
      paraantcatini = create_tribe 'Paraantcatini', subfamily: paraantcatinae

      paraantcatia = create_genus 'Paraantcatia', tribe: paraantcatini, fossil: true
      %w[subplanifrons orientalis shinshuensis sompoensis].each do |species|
        create_species "Paraantcatia #{species}", genus: paraantcatia, fossil: true
      end

      puts "Creating users..."
      User.create! email: 'user@example.com', name: 'Test User', password: 'secret123'
      editor = User.create! email: 'editor@example.com', name: 'Test Editor', password: 'secret123'
      editor.add_role :editor
      superadmin = User.create! email: 'superadmin@example.com', name: 'Test Superadmin', password: 'secret123'
      superadmin.add_role :editor
      superadmin.add_role :superadmin

      puts "Successfully imported sample data."
    end
  end
end
