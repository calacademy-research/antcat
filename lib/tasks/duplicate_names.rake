namespace :antcat do
  desc "Show duplicate names and their references"
  task show_duplicate_names_with_references: :environment do
    names_with_duplicates = Names::DuplicatesWithReferences[show_progress: true]
    names_with_duplicates.each do |name, name_with_duplicates|
      puts
      puts name
      name_with_duplicates.each do |id, duplicates|
        print id
        duplicates.each do |duplicate|
          print " #{duplicate[:table]} #{duplicate[:field]} #{duplicate[:id]}"
          puts
        end
        puts ' -' if duplicates.size.zero?
      end
    end
  end
end
