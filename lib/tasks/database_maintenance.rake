# TODO cleanup and split this file.
# TODO move most code to somehere else and call it from here.

require 'antcat_rake_utils'
include AntCat::RakeUtils

namespace :antcat do
  namespace :db do

    # WIP
    desc "Find tag by id, eg {ref 142238} --> `rake antcat:db:find_tagged_id[142238]`"
    task :find_tagged_id, [:id] => [:environment] do |t, args|
      id_to_find = args[:id]

      abort "Query for ids like this: rake antcat:db:find_tagged_id[142238]" unless id_to_find

      tags = {
        ref: Reference,
        nam: Name,
        tax: Taxon,
      }
      def tags.keys_plus_empty_arrays
        map { |tag, _| [tag, []] }.to_h
      end

      puts "Searching... (in '#{Rails.env}' database)"
      matched_ids = tags.keys_plus_empty_arrays
      models_with_taxts.each_field do |field, model|
        tags.each_key do |tag|
          model.where("#{field} LIKE '%{#{tag} #{id_to_find}}%'").find_each do |matched_obj|
            puts "found: #{matched_obj.inspect}"
          end
        end
      end

      puts "Done."
    end
  end
end
