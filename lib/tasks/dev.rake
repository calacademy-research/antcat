# Useful if you want to experiment locally with the code after cloning the git repo.
# If you want to develop locally with real data, please contact AntCat to request a database dump.

if Rails.env.development? || Rails.env.test?
  namespace :dev do
    desc "Sample data for local development environment"
    task prime: [:environment] do
      require 'factory_bot'
      require 'sunspot_test'

      include FactoryBot::Syntax::Methods
      SunspotTest.stub

      create :family # Formicidae, the family of all ants.
      antcatinae = create :subfamily, name_string: 'Antcatinae'
      antcatini = create :tribe, name_string: 'Antcatini', subfamily: antcatinae

      # Create a bunch of species and subspecies.
      antcatia = create :genus, name_string: 'Antcatia', tribe: antcatini
      antcatia_tigris = create :species, name_string: 'Antcatia tigris', genus: antcatia
      %w[corbetti jacksoni sumatrae].each do |subspecies|
        create :subspecies, name_string: "Antcatia tigris #{subspecies}",
          subfamily: antcatinae, genus: antcatia, species: antcatia_tigris
      end
      puts "Created taxa."

      user = User.create!(email: 'editor@example.com', name: 'Test Editor', password: 'secret123', editor: true, superadmin: true)
      puts "Created user '#{user.email}' with password 'secret123'."
    end
  end
end
