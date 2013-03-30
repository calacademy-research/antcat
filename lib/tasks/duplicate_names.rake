# coding: UTF-8
desc "Show duplicate names and their references"
task show_duplicate_names_with_references: :environment do
  Name.duplicates_with_references.each do |key, value|
    name = Name.find key
    puts "#{name.name} #{name.id}"
  end
end
