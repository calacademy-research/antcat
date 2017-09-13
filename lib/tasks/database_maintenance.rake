# TODO cleanup and split this file.
# TODO move most code to somehere else and call it from here.

require 'antcat_rake_utils'
include AntCat::RakeUtils

namespace :antcat do
  namespace :db do
    # See also `DatabaseScripts::Scripts::BrokenTaxtTags`.
    desc "Finds all tags, eg {ref 133005}, that are referred to but doesn't exist"
    task broken_tags: :environment do
      tags = {
        ref: Reference,
        nam: Name,
        tax: Taxon,
        #epi:           #TODO? /{epi (\w+)}/
        #?:             #TODO? Not sure what this is, but it looks like this "{? #{string}}"
      }
      def tags.keys_plus_empty_arrays
        map { |tag, _| [tag, []] }.to_h
      end

      puts "Searching... (in '#{Rails.env}' database)"
      matched_ids = tags.keys_plus_empty_arrays
      models_with_taxts.each_field do |field, model|
        puts "  #{model} --> #{field}..."
        tags.each_key do |tag|
          matched_ids[tag] += find_all_tagged_ids model, field, tag
        end
      end
      matched_ids.each_value &:uniq!

      matched_ids_statistics = matched_ids.map do |tag, ids|
        "#{ids.size} #{tag}(s)"
      end.to_sentence

      puts "Found #{matched_ids_statistics} (unique only). Searching for non-existing..."
      broken_ids = tags.keys_plus_empty_arrays
      broken_ids.each_item_in_arrays_alias :each_id
      matched_ids.each do |tag, ids|
        broken_ids[tag] = reject_existing tags[tag], ids
      end

      puts "Found no broken tags." and next if broken_ids.all? &:empty?

      broken_ids_statistics = broken_ids.map { |tag, ids| "#{ids.size} #{tag}(s)" }.to_sentence
      antcat_prompt "Found #{broken_ids_statistics}. List which? [Y/n/q]" do
        broken_ids.each { |tag, ids| puts "#{tag}: #{ids}" }
      end

      antcat_prompt "Search destroyed? [Y/n/q]" do
        broken_ids.each_id do |id, tag|
          PaperTrail::Version.where(event: 'destroy', item_type: tags[tag].to_s, item_id: id).each do |version|
            puts "Found #{tag} ##{id} (version id #{version.id}, #{version.event}): #{version.reify.to_s}"
          end
        end
      end

      antcat_prompt "Search *any* version? (may take a while) [Y/n/q]" do
        broken_ids.each_id do |id, tag|
          PaperTrail::Version.where(item_id: id).each do |version|
            puts "Found #{tag} ##{id} (version id #{version.id}): #{version.reify}"
          end
        end
      end

      antcat_prompt "Search for matching ids in other models (Reference, Name, Taxon)? [Y/n/q]" do
        [Reference, Name, Taxon].each do |model|
          model.where(id: broken_ids.each_id).each { |item| puts "#{model.to_s}: #{item.id}" }
        end
      end

      antcat_prompt "List affected taxa? [Y/n/q]" do
        taxon_id_field = {
          ReferenceSection => 'taxon_id',
          TaxonHistoryItem => 'taxon_id',
          Taxon            => 'id'
        }
        taxon_id_field.default = "id"

        taxa_with_broken_ids = []
        models_with_taxts.each_field do |field, model|
          tags.each_key do |tag|
            model.where("#{field} LIKE '%{#{tag} %'").find_each do |matched_obj|
              matched_ids = extract_tagged_ids matched_obj.send(field), tag
              broken_matched_ids = matched_ids & broken_ids[tag]

              unless broken_matched_ids.empty?
                affected_taxon = case matched_obj
                                 when Citation then "Unknown"
                                 else matched_obj.send(taxon_id_field[model]).to_i end
                number_of_uniqe_broken_ids = broken_matched_ids.size

                taxa_with_broken_ids << [
                  affected_taxon,
                  tag,
                  model.to_s,
                  field,
                  number_of_uniqe_broken_ids,
                  broken_matched_ids
                ]
              end
            end
          end
        end
        taxa_with_broken_ids.each { |taxon| puts "#{taxon}" }
        puts "\naffected_taxon | tag | model | field | number_of_uniqe_broken_ids | broken_matched_ids"
      end

      puts "Done."
    end
  end
end

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
