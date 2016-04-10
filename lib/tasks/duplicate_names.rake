desc "Show duplicate names and their references"
task show_duplicate_names_with_references: :environment do
  duplicates = Name.duplicates_with_references show_progress: true
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
