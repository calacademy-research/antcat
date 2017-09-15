# TODO move most code to somehere else and call it from here.

namespace :antcat do
  desc "Show duplicate names and their references"
  task show_duplicate_names_with_references: :environment do
    duplicates = Names::DuplicatesWithReferences[show_progress: true]
    duplicates.each do |name, duplicates|
      puts
      puts name
      duplicates.each do |id, duplicates|
        print id
        duplicates.each do |duplicate|
          print " #{duplicate[:table]} #{duplicate[:field]} #{duplicate[:id]}"
          puts
        end
        puts if duplicates.size.zero?
      end
    end
  end
end
