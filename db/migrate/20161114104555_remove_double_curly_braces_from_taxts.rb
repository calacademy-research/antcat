# We want to remove double curly braces such as shown here:
# TaxonHistoryItem.find(239431).taxt
#  => "{tax 429013} as junior synonym of {tax 429411}: {ref 124002}}: 55."
#
# In action: "Dalla Torre, 1893}", http://localhost:3000/catalog/429013
#
# Code copy-pasted from `lib/tasks/database_maintenance.rake`

require 'antcat_rake_utils'
include AntCat::RakeUtils

class RemoveDoubleCurlyBracesFromTaxts < ActiveRecord::Migration
  def up
    puts "double_braces_count before: #{double_braces_count}".red

    Feed.without_tracking do
      remove_double_braces
    end

    puts "double_braces_count after: #{double_braces_count}".green
  end

  def down
  end
end

def remove_double_braces
  models_with_taxts.each_field do |field, model|
    model.where("#{field} LIKE '%}}%'").find_each do |matched_obj|
      cleaned_string = matched_obj.send(field).gsub(/\}\}/, "}")
      matched_obj.update_columns field => cleaned_string
    end
  end
end

def double_braces_count
  count = 0
  models_with_taxts.each_field do |field, model|
    count += model.where("#{field} LIKE '%}}%'").count
  end
  count
end
